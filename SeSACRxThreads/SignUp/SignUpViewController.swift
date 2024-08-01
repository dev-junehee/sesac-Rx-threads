//
//  SignUpViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

enum ErrorType: Error {
    case invalidEmail
}

class SignUpViewController: UIViewController {

    let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    let validationButton = UIButton()
    let nextButton = PointButton(title: "다음")
        
    // let emailData = Observable.just("howl@howl.com")    // Observable: 이벤트를 보내는 역할
    
    let emailData = BehaviorSubject(value: "howl@howl.com") // Subject: 이벤트를 보내는 역할 + 이벤트를 처리하는 역할
    // let emailData = PublishSubject<String>()
    
    let basicColor = Observable.just(UIColor.systemBlue)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        configure()
        
        // RxSwift 안쓴 버전 -> button.rx.tap
        // nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
        
        bind()
    }
    
    func testPublishSubject() {
        let example = PublishSubject<String>()
        
        // 구독 전에 complete를 보낸다면
        // example.onCompleted()
        
        // 구독 전에 에러를 보낸다면
        // example.onError(ErrorType.invalidEmail)
        
        example.onNext("AAA")
        // == example.on(.next("BBB))
        
        example.subscribe { value in
            print("Publish :", value)
        } onError: { error in
            print("Publish :", error)
        } onCompleted: {
            print("Publish Completed")
        } onDisposed: {
            print("Publish Disposed")
        }
        .disposed(by: disposeBag)
        
        example.onNext("CCC")
        // example.onCompleted()   // -> 바로 dispose 처리됨
        // example.onError(ErrorType.invalidEmail)  // -> 바로 dispose 처리됨
        example.onNext("DDD")   // dispose 이후로는 실행되지 않음
    }
    
    func bind() {
        let validation = emailTextField
            .rx
            .text       // ControlProperty<String?>
            .orEmpty    // ControlProperty<String>
            .map { $0.count >= 4 }  // Observable<Result>
        
        validation
            .bind(to: nextButton.rx.isEnabled, validationButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        validation
            .bind(with: self) { owner, value in
                let color: UIColor = value ? .systemBlue : .systemRed
                owner.nextButton.backgroundColor = color
                owner.validationButton.isHidden = !value
            }
            .disposed(by: disposeBag)
        
        emailData
            .bind(to: emailTextField.rx.text)
            .disposed(by: disposeBag)
        
        
        validationButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.emailData.onNext("b@b.com") /// emailData.text = "b@b.com"
            }
            .disposed(by: disposeBag)
        
        basicColor
            .bind(to: nextButton.rx.backgroundColor, 
                  emailTextField.rx.textColor,
                  emailTextField.rx.tintColor
                  // emailTextField.rx.layer.borderColor    // 왜 borderColor 안 나올까? 타입이 다름! UIColor-cgColor
            )
            .disposed(by: disposeBag)
        
        basicColor
            .map { $0.cgColor } // UIColor를 cgColor로 변경하여 사용
            .bind(to: emailTextField.layer.rx.borderColor)
            .disposed(by: disposeBag)
        

        // RxSwift로 핸들러 설정 (기존 addTarget)
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(PasswordViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    // @objc func nextButtonClicked() {
    //     navigationController?.pushViewController(PasswordViewController(), animated: true)
    // }

    func configure() {
        validationButton.setTitle("중복확인", for: .normal)
        validationButton.setTitleColor(Color.black, for: .normal)
        validationButton.layer.borderWidth = 1
        validationButton.layer.borderColor = Color.black.cgColor
        validationButton.layer.cornerRadius = 10
    }
    
    func configureLayout() {
        view.addSubview(emailTextField)
        view.addSubview(validationButton)
        view.addSubview(nextButton)
        
        validationButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.equalTo(100)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.trailing.equalTo(validationButton.snp.leading).offset(-8)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    

}
