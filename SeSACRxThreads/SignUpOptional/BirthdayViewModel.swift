//
//  BirthdayViewModel.swift
//  SeSACRxThreads
//
//  Created by junehee on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class BirthdayViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let birthday: ControlProperty<Date>
        let nextButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let year: BehaviorRelay<Int>
        let month: BehaviorRelay<Int>
        let day: BehaviorRelay<Int>
        let nextButtonTap: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        let year = BehaviorRelay(value: 0000)
        let month = BehaviorRelay(value: 0000)
        let day = BehaviorRelay(value: 0000)
        
        input.birthday
            .bind(with: self) { owner, date in
                print(date)
                
                let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
                
                year.accept(component.year!) // Relay에서 사용하는 onNext = accept
                month.accept(component.month!)
                day.accept(component.day!)
                
            }
            .disposed(by: disposeBag)

        
        return Output(year: year, 
                      month: month,
                      day: day,
                      nextButtonTap: input.nextButtonTap)
    }
    
}
