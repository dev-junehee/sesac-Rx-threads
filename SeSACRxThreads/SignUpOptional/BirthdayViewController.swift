//
//  BirthdayViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class BirthdayViewController: UIViewController {
    
    let birthDayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    
    let infoLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.text = "만 17세 이상만 가입 가능합니다."
        return label
    }()
    
    let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10 
        return stack
    }()
    
    let yearLabel: UILabel = {
       let label = UILabel()
        label.text = "2023년"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let monthLabel: UILabel = {
       let label = UILabel()
        label.text = "33월"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let dayLabel: UILabel = {
       let label = UILabel()
        label.text = "99일"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
  
    let nextButton = PointButton(title: "가입하기")
    
    // 로드되자마자 화면에 바로 나타나지 않음 (초기값을 가지고 있지 않기 때문에)
    // let year = PublishSubject<Int>()
    // let month = PublishSubject<Int>()
    // let day = PublishSubject<Int>()
    
    // let year = BehaviorSubject(value: 0000)
    // let month = BehaviorSubject(value: 00)
    // let day = BehaviorSubject(value: 0)
    
    let year = BehaviorRelay(value: 0000)
    let month = BehaviorRelay(value: 00)
    let day = BehaviorRelay(value: 0)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        
        bind()
    }
    
    private func bind() {
        birthDayPicker.rx.date
            .bind(with: self) { owner, date in
                print(date)
                
                let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
                // print(component.year)
                // print(component.month)
                // print(component.day)
                
                // owner.yearLabel.text = "\(component.year ?? 0)년"
                // owner.monthLabel.text = "\(component.month ?? 0)월"
                // owner.dayLabel.text = "\(component.day ?? 0)일"
                
                owner.year.accept(component.year!) // Relay에서 사용하는 onNext = accept
                owner.month.accept(component.month!)
                owner.day.accept(component.day!)
                
            }
            .disposed(by: disposeBag)
        
        /// 아래 `year, month, day` 할당하는 방법 3가지가 모두 똑같이 동작함!
        /// year가 yearLabel에 표시되는 것이 실패할 경우는 없다.
        /// 그래서 complete, error 처리를 해줄 필요가 없는 bind를 사용한다.
        year
            .map({ "\($0)년" })
            .bind(to: yearLabel.rx.text)
            .disposed(by: disposeBag)
        
        month
            .bind(with: self) { owner, value in
                owner.monthLabel.text = "\(value)월"
            }
            .disposed(by: disposeBag)
        
        day
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, value in
                owner.dayLabel.text = "\(value)일"
            }
            .disposed(by: disposeBag)
        
        
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(SearchViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }

    func configureLayout() {
        view.addSubview(infoLabel)
        view.addSubview(containerStackView)
        view.addSubview(birthDayPicker)
        view.addSubview(nextButton)
 
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            $0.centerX.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        [yearLabel, monthLabel, dayLabel].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        birthDayPicker.snp.makeConstraints {
            $0.top.equalTo(containerStackView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
   
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(birthDayPicker.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
