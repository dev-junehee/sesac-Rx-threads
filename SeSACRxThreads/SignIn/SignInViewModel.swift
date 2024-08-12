//
//  SignInViewModel.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import Foundation
import RxCocoa
import RxSwift

protocol BaseViewModel {
    associatedtype Input
    associatedtype Output
    
    // var disposeBag: DisposeBag { get }
    
    func transform(input: Input) -> Output
}

// class TestViewModel: BaseViewModel {
// 
//     /// 같은 네이밍이면 생략 가능. Input-Output  별칭 생략 가능!
//     // typealias Input = Input
//     // typealias Output = Output
//     
//     struct Input {
//         
//     }
//     
//     struct Output {
//         
//     }
//     
//     func transform(input: Input) -> Output {
//         //
//     }
//     
// }

class SignInViewModel: BaseViewModel {
    
    
    struct Input {
        let tap: ControlEvent<Void>
        
    }
    
    struct Output {
        // let text: PublishRelay<String>  // 이벤트를 주고받기 위해 PublishSubject > next만 처리하기 위해 PublilshRelay
        let text: Driver<Joke>
    }
    
    func transform(input: Input) -> Output {
        let result = input.tap
            .flatMap {
                // NetworkManager.shared.fetchJoke()
                NetworkManager.shared.fetchJokeWithSingle()
                    // 네트워크 통신 이후에 처리할 수도 있다.
                    .catch{ error in
                        return Single<Joke>.never()
                    }
            }
        // .asSingle()
            // .catch { error in    // 에러일 때만 반응
            //     return Observable.just(Joke(id: 0, joke: "실패했어용"))  // 예외처리한 값을 전달
            // }
            .asDriver(onErrorJustReturn: Joke(id: 0, joke: "실패!!!!!!"))
            .debug("Button Tap")
        
        return Output(text: result)
    }
    
    // 1. asSingle()
    // 뷰에 결과가 안 나온다. ButtonTap 이벤트 전달이 안된다. 두 번째 버튼은 실패로 나온다. 세번째 부터는 클릭도 안된다.
    // -> asSingle은 전체 스트림을 single로 변환해주기 때문
    
    // 2. 탭 옵저버블 내에 네트워크 옵저버블이 있는데,
    // 탭 옵저버블은 살아있고, 네트워크만 사라져야하는데 네트워크가 오류를 뱉으면 탭도 함께 dispose 되고 있다.
    // 즉 자식이 내뱉은 오류에 부모가 영향을 받고 있는 것!
    // JokeAPI가 에러를 뱉으면 네트워크 통신만 dispose 되어야 하지만, Button Tap까지 dispose 되어서 이후 Tap 이벤트가 발생하지 못하는 오류가 생긴다.
    
    // 따라서 뭐가 필요한가?
    
    // 3. 자식 스트림이 에러를 방출하더라도 부모 스트림이 에러를 안 받고 dispose되지 않도록 처리하는 것이 중요하다.
    // -> 에러 처리 + 스트림 유지!
    // Observable, Single 두가지 모두 적용 가능함
    
    // 3-1. 중간에 에러를 직접 처리해주기 (.catch)
    /// `catch`는 에러일 때만 반응한다.
    /// driver 이전에 처리하거나, Network 호출 이후에 처리할 수도 있다.
    /// 이렇게 처리하면 오류가 났을 때 네트워크 호출만  dispose되고, 버튼 탭 이벤트는 계속 발생!
    

    // 3-2. Result 타입 사용
    
}
