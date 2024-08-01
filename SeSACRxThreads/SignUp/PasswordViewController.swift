//
//  PasswordViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class PasswordViewController: UIViewController {
   
    let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    let descriptionLabel = UILabel()
    
    let disposeBag = DisposeBag()
    
    /**
     1. 비밀번호 텍스트필드가 8자리 이상일 때 true
     2. true일 때 버튼 활성화(isEnabled)
     3. 버튼을 클릭했을 때 화면전환 코드 RxSwift로 변경
     4. descriptionLabel 임시로 추가
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
         
        // nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(PhoneViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        bind()
    }
    
    func bind() {
        descriptionLabel.text = "8자리 이상 입력해 주세요."
        
        let validation = passwordTextField
            .rx
            .text
            .orEmpty
            .map { $0.count < 8 }
        
        validation
            .bind(with: self) { owner, value in     // 8자리보다 작을 때
                owner.nextButton.isEnabled = !value
                owner.descriptionLabel.isHidden = !value
                
                let color: UIColor = value ? .lightGray : .systemBlue
                owner.nextButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
    }
    
    @objc func nextButtonClicked() {
        navigationController?.pushViewController(PhoneViewController(), animated: true)
    }
    
    func configureLayout() {
        view.addSubview(passwordTextField)
        view.addSubview(nextButton)
        view.addSubview(descriptionLabel)
         
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(nextButton.snp.top)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
