//
//  BoxOfficeViewController.swift
//  SeSACRxThreads
//
//  Created by junehee on 8/7/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class BoxOfficeViewController: UIViewController {
    
    private let searchBar = UISearchBar()
    private let collectionView = UICollectionView(frame: .zero, 
                                                  collectionViewLayout: layout())
    private let tableView = UITableView()
    
    
    private let viewModel = BoxOfficeViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bind()
    }
    
    private func bind() {
        let recentText = PublishSubject<String>()
        
        let input = BoxOfficeViewModel.Input(recentText: recentText, 
                                             searchButtonTap: searchBar.rx.searchButtonClicked,
                                             searchText: searchBar.rx.text.orEmpty)
        let output = viewModel.transform(input: input)
        
        output.recentList
            .bind(to: collectionView.rx.items(cellIdentifier: MovieCollectionViewCell.identifier, cellType: MovieCollectionViewCell.self)) { (row, element, cell) in
                cell.label.text = "\(element), \(row)"
            }
            .disposed(by: disposeBag)
        
        output.movieList
            .bind(to: tableView.rx.items(cellIdentifier: MovieTableViewCell.identifier, cellType: MovieTableViewCell.self)) { (row, element, cell) in
                cell.appNameLabel.text = element
            }
            .disposed(by: disposeBag)
        
        // zip - 옵저버블 두 개를 동시에!
        Observable.zip(tableView.rx.modelSelected(String.self),
                       tableView.rx.itemSelected)
        .map { "검색어는 \($0.0)" }
        .subscribe(with: self) { owner, value in
            recentText.onNext(value)
        }
        .disposed(by: disposeBag)
        
        // tableView.rx.modelSelected(String.self)
        //     .subscribe(with: self) { owner, value in
        //         print("modelSelected", value)
        //     }
        //     .disposed(by: disposeBag)
        // 
        // tableView.rx.itemSelected
        //     .subscribe(with: self) { owner, value in
        //         print("itemSelected", value)
        //     }
        //     .disposed(by: disposeBag)
        
    }
    
    private func configure() {
        view.backgroundColor = .white
        [searchBar, tableView, collectionView].forEach { view.addSubview($0) }
        navigationItem.titleView = searchBar
        
        collectionView.backgroundColor = .lightGray
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(50)
        }
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        
        tableView.backgroundColor = .gray
        tableView.rowHeight = 100
        tableView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
    }
    
    static func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 40)
        layout.scrollDirection = .horizontal
        return layout
    }
    
}
