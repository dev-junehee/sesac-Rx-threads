//
//  SearchViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 8/1/24.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
   
    private let tableView: UITableView = {
       let view = UITableView()
        view.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        view.backgroundColor = .white
        view.rowHeight = 180
        view.separatorStyle = .none
       return view
     }()
    
    let searchBar = UISearchBar()
       
    let disposeBag = DisposeBag()
    
    var data = ["A", "B", "C", "AB", "D", "ABC", "BBB", "EC", "SA", "AAAB", "ED", "F", "G", "H"]
    lazy var list = BehaviorSubject(value: data)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configure()
        setSearchController()
        bind()
    }
    
    func bind() {
        list
            .bind(to: tableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) { (row, element, cell) in
                 
                cell.appNameLabel.text = element
                cell.appIconImageView.backgroundColor = .systemBlue
                
                cell.downloadButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.navigationController?.pushViewController(DetailViewController(), animated: true)
                    }
                    .disposed(by: cell.disposeBag)  // 이 부분 유념!

            }
            .disposed(by: disposeBag)
        
        // Rx에서 searchBarSearchButtonClicked
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text.orEmpty) { void, text in
                return text
            }
            .bind(with: self) { owner, text in  // searchButtonClicked 값과, withLatestFrom에서 처리된 값이 같이 들어옴! (지금은 return text만 해줬기 때문에 text만)
                // guard let word = owner.searchBar.text else { return }
                owner.data.insert(text, at: 0)
                owner.list.onNext(owner.data)
            }
            .disposed(by: disposeBag)
        
        /// `Debounce vs Throttle`
        // searchBar.rx.text.orEmpty
        //     .debounce(.milliseconds(500), scheduler: MainScheduler.instance) // 실시간 검색을 하는데 ~초 기다렸다가 이후 코드 실행해줘!
        //     .distinctUntilChanged()
        //     .bind(with: self) { owner, value in
        //         print("실시간 검색", value)
        //         let result = value.isEmpty ? owner.data : owner.data.filter { $0.contains(value) }
        //         owner.list.onNext(result)
        //     }
        //     .disposed(by: disposeBag)
    }
     
    private func setSearchController() {
        view.addSubview(searchBar)
        navigationItem.titleView = searchBar
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(plusButtonClicked))
    }
    
    @objc func plusButtonClicked() {
        print("추가 버튼 클릭")
    }

    
    private func configure() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

    }
}
