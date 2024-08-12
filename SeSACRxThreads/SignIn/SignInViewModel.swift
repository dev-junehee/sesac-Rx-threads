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
        let text: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let result = input.tap
            .map { "a@a.com" }
            .asDriver(onErrorJustReturn: "b@b.com")
            
        return Output(text: result)
    }
    
    
}
