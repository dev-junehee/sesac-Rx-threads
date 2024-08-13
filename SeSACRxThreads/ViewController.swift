//
//  ViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
// import Combine

/**
 50회차 강의자료: Unicast, Multicast
 52회차 강의자료: Hot Observable, Cold Observable
 
 RxCommunity > RxDataSource 정도는 사용해봄직함 ! - RxExample 예시 있음
 zip - combineLatest - withLatestFrom 의 차이
 debounce - throuttle 차이
 
` RxSwift  vs Combine (iOS 13+)`
 - Observer vs Publisher
 - Observable vs Subscriber
 - Subscribe vs Sink
 - Dispose vs AnyCancallable
 - PublishSubject vs PassthroughSubject
 - BehaviorSubject vs CurrentValueSubject
 
 `LSLP`
 - MVVM - Input. Output. - RxSwift 사용
 */

class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    let nextButton = PointButton(title: "다음")
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        // bind()
        bind2()
    }
    
    private func bind() {
        nextButton.rx.tap
            .flatMap {
                self.childObservableResultType()
                
                // self.childObservable()
                //     .catch { error in
                //         // print("catch", error)
                //         // return Observable.just(404) // 여기서 바로 내보내도 되고,
                //         self.errorObservable()         // 에러 처리가 가능한 옵저버블 함수를 별도로 실행해줘도 된다.
                //     }
            }
            .subscribe(with: self) { owner, value in
                print(">>> Next", value)
                
                // 에러도 onNext를 통해 전달되기 때문에 값을 구분하기 위해 switch 사용
                switch value {
                case .success(let value):
                    print("Success", value)
                case .failure(let error):
                    print("Fail", error)
                }
            } onError: { owner, error in
                print(">>> Error", error)
            } onCompleted: { owner in
                print(">>> Completed")
            } onDisposed: { owner in
                print(">>> Disposed")
            }
            .disposed(by: disposeBag)
    }
    
    private func childObservable() -> Observable<Int> {
        return Observable.create { observer in
            /// 1 - 정상적인 종료
            /// childObservable이 버튼을 탭할 때 마다 계속 subscribe 되기 때문에 이를 방지하기 위해 onNext 이후 onComplete 되게 처리
            // observer.onNext(Int.random(in: 1...10))
            // observer.onCompleted()
            
            /// 2 - 비정상적인 종료
            /// childObservable이 에러를 반환하기 때문에 무조건 disposed 된다. 따라서 버튼을 탭하는 스트림도 함께 disposed 된다.
            /// = 자식 스트림에서 반환된 에러로 인해 부모 스트림도 함께 disposed 되는 것.
            // observer.onError(ErrorType.invalidEmail)
            
            
            return Disposables.create()
        }.debug("childObservable")
    }
    
    // 에러 대응 예외처리를 위한 옵저버블 방출
    private func errorObservable() -> Observable<Int> {
        return Observable.create { observer in
            observer.onNext(404)
            observer.onCompleted()
            return Disposables.create()
        }.debug("childObservable")
    }
    
    // Error 이벤트를 보내야하는 상황에서도 error를 안 내보내는 방법은 없을까?
    /// 내가 보내는 건 에러지만, 에러 자체를 onNext에 보내버리기
    private func childObservableResultType() -> Observable<Result<Int, ErrorType>> {
        return Observable.create { observer in
            // observer.onNext(.success(//성공했을 때 보낼 값))
            observer.onNext(.failure(.invalidEmail)) // 실패했을 때도 onNext로 처리
            observer.onCompleted()
            return Disposables.create()
        }.debug("childObservableResultType")
    }
    
    
    private func bind2(){
        nextButton.rx.tap
            // .flatMap {
            //     NetworkManager.shared.fetch()
            //         .catch { error in
            //             print("catch", error)
            //             // return Observable.just(Joke(id: 0, joke: "Error"))
            //             return self.errorJokeObservable()
            //         }
            // }
            // .flatMap {
            //     NetworkManager.shared.fetchJokeWithSingle()
            //         .catch { error in
            //             print("catch", error)
            //             let joke = Joke(id: 0, joke: "Error")
            //             return Single<Joke>.just(joke)
            //         }
            // }
            .flatMap {
                NetworkManager.shared.fetchJokeWithSingleResultType()
            }
            .subscribe(with: self) { owner, value in
                print(">>> Next", value)
                
                switch value {
                case .success(let value):
                    print(value)
                case .failure(let error):
                    print(error)
                }
            } onError: { owner, error in
                print(">>> Error", error)
            } onCompleted: { owner in
                print(">>> Completed")
            } onDisposed: { owner in
                print(">>> Disposed")
            }
            .disposed(by: disposeBag)
    }
    
    private func errorJokeObservable() -> Observable<Joke> {
        return Observable.create { observer in
            observer.onNext(Joke(id: 0, joke: "ERROR"))
            observer.onCompleted()
            return Disposables.create()
        }
    }

}

