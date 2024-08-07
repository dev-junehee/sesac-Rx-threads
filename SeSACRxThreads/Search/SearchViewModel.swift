//
//  SearchViewModel.swift
//  SeSACRxThreads
//
//  Created by junehee on 8/7/24.
//

import Foundation
import RxSwift

final class SearchViewModel {
    
    // input
    let inputQuery = PublishSubject<String>() // searchBar.rx.text.orEmpty
    let inputSearchButtonTap = PublishSubject<Void>() // searchBar.rx.searchButtonClicked
    
    // dummy
    private var data = ["A", "B", "C", "AB", "D", "ABC", "BBB", "EC", "SA", "AAAB", "ED", "F", "G", "H"]
    
    // output
    lazy var list = BehaviorSubject(value: data)
    
    private let disposeBag = DisposeBag()
    
    init() {
        inputQuery
            .subscribe(with: self) { owner, value in
                print("inputQueqry 변경", value)
            }
            .disposed(by: disposeBag)
        
        // inputSearchButtonTap
        //     .withLatestFrom(inputQuery)
        //     .subscribe(with: self) { owner, value in
        //         print("inputSearchButtonTap 클릭됨", value)
        //         owner.data.insert(value, at: 0)
        //         owner.list.onNext(owner.data)
        //     }
        //     .disposed(by: disposeBag)
        
        inputQuery
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance) // 실시간 검색을 하는데 ~초 기다렸다가 이후 코드 실행해줘!
            .distinctUntilChanged()
            .subscribe(with: self) { owner, value in
                print("실시간 검색", value)
                let result = value.isEmpty ? owner.data : owner.data.filter { $0.contains(value) }
                owner.list.onNext(result)
            }
            .disposed(by: disposeBag)

    }
    
    
}
