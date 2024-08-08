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
    
    // 컬렉션뷰
    // let recentList: Observable<[String]> = Observable.just(["b", "c"])
    var recentList = ["b", "a"]
    
    struct Input {
        let recentText: PublishSubject<String>  // 테이블뷰 셀 클릭 시 들어오는 텍스트 (컬렉션 뷰에 업데이트)
        let searchButtonTap: ControlEvent<Void>
        let searchText: ControlProperty<String>
    }
    
    struct Output {
        let boxOfficeList: Observable<[DailyBoxOfficeList]>     // 테이블뷰에서 사용
        let recentList: BehaviorSubject<[String]>           // 컬렉션뷰
    }
    
    func transform(input: Input) -> Output {
        let recentList = BehaviorSubject(value: recentList)
        let boxOfficeList = PublishSubject<[DailyBoxOfficeList]>()
        
        input.recentText
            .subscribe(with: self) { owner, value in
                print("ViewModel Transform", value)
                owner.recentList.append(value)
                recentList.onNext(owner.recentList)
            }
            .disposed(by: disposeBag)
        
        // 엔터키 클릭 시 서버 통신 진행
        input.searchButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)   // 1초 뒤에 실행
            .withLatestFrom(input.searchText)   // 마지막으로 작성된 값 가져오기 e.g)20240701
            .debug("체크1")
            .distinctUntilChanged()     // 값이 같으면 실행X
            .map {
                guard let intText = Int($0) else {  // 예외처리
                    return 20240701
                }
                return intText
            }
            .debug("체크2")
            .map { return "\($0)" } // 문자열로 변환
            .flatMap { date in  // Observable<Movie>로 넘어오는 것을 바로 Movie로 풀어주기 위해 flatMap 사용
                NetworkManager.shared.callBoxOffice(date: date)
            }
            .subscribe(with: self) { owner, movie in
                dump(movie.boxOfficeResult.dailyBoxOfficeList)
                boxOfficeList.onNext(movie.boxOfficeResult.dailyBoxOfficeList)
            } onError: { owner, error in
                print("Error:", error)
            } onCompleted: { value in
                print("Completed")
            } onDisposed: { value in
                print("Disposed")
            }
            .disposed(by: disposeBag)
        
            
            // .map { date in
            //     NetworkManager.shared.callBoxOffice(date: date)
            // }
            // .subscribe(with: self, onNext: { owner, value in
            //     // 여기서 넘어오는 값은 Observable<Movie>이기 때문에 실질적인 데이터가 아니라 이벤트!
            //     // 한번 더 구독을 통해 진짜 필요한 데이터를 가져오기
            //     value
            //         .subscribe(with: self) { owner, movie in
            //             print(movie.boxOfficeResult.dailyBoxOfficeList)
            //         }
            //         .disposed(by: owner.disposeBag)
            // })
            // .disposed(by: disposeBag)
        
        input.searchText
            .subscribe(with: self) { owner, value in
                print("뷰모델 글자 인식", value)
            }
            .disposed(by: disposeBag)
        
        
        return Output(boxOfficeList: boxOfficeList, recentList: recentList)
    }
    
}
