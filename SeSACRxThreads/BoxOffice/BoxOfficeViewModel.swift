//
//  BoxOfficeViewModel.swift
//  SeSACRxThreads
//
//  Created by junehee on 8/7/24.
//

import Foundation
import RxSwift
import RxCocoa

final class BoxOfficeViewModel {
    
    private let disposeBag = DisposeBag()
    
    // 테이블뷰 더미 데이터
    let movieList = Observable.just(["테스트1", "테스트2", "테스트3"])
    
    // 컬렉션뷰
    // let recentList: Observable<[String]> = Observable.just(["b", "c"])
    var recentList = ["b", "a"]
    
    struct Input {
        let recentText: PublishSubject<String>  // 테이블뷰 셀 클릭 시 들어오는 텍스트 (컬렉션 뷰에 업데이트)
        let searchButtonTap: ControlEvent<Void>
        let searchText: ControlProperty<String>
    }
    
    struct Output {
        let movieList: Observable<[String]>         // 테이블뷰에서 사용
        let recentList: BehaviorSubject<[String]>    // 컬렉션뷰
    }
    
    func transform(input: Input) -> Output {
        let recentList = BehaviorSubject(value: recentList)
        
        input.recentText
            .subscribe(with: self) { owner, value in
                print("ViewModel Transform", value)
                owner.recentList.append(value)
                recentList.onNext(owner.recentList)
            }
            .disposed(by: disposeBag)
        
        input.searchButtonTap
            .subscribe(with: self) { owner, _ in
                print("뷰모델 서치 버튼 탭 인식")
            }
            .disposed(by: disposeBag)
        
        input.searchText
            .subscribe(with: self) { owner, value in
                print("뷰모델 글자 인식", value)
            }
            .disposed(by: disposeBag)
        
        
        return Output(movieList: movieList, recentList: recentList)
    }
    
}
