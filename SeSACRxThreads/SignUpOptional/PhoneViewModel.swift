//
//  PhoneViewModel.swift
//  SeSACRxThreads
//
//  Created by junehee on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PhoneViewModel {
    
    struct Input {
        let tap: ControlEvent<Void> // nextButton.rx.tap
        let text: ControlProperty<String?>  // phoneTextField.rx.text
    }
    
    struct Output {
        let tap: ControlEvent<Void>
        let validText: Observable<String>
        let validation: Observable<Bool>
    }
    
    func transform(input: Input) -> Output {
        let validation = input.text.orEmpty.map { $0.count >= 8 }
        
        let validText = Observable.just("연락처는 8자리 이상입니다.")
        
        return Output(tap: input.tap,
                      validText: validText,
                      validation: validation)
    }
    
}
