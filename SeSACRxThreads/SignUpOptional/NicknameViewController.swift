//
//  NicknameViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class NicknameViewController: UIViewController {
   
    let nicknameTextField = SignTextField(placeholderText: "닉네임을 입력해주세요")
    let nextButton = PointButton(title: "다음")
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        configureLayout()
        // nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
        bind()
    }
    
    // @objc func nextButtonClicked() {
    //     navigationController?.pushViewController(BirthdayViewController(), animated: true)
    // }
    
    func bind() {
        /// 아래 코드를 실행하면 test라는 걸 공유하고 있지만 랜덤한 Int 값이 출력된다.
        /// 즉, Observable Stream이 공유되지 않는다.
        /// 보통 구독을 할 때 마다 새로운 Stream이 생기기 때문에, 아래와 같은 코드는 버튼을 3번 클릭한 것과 같다.
        /// 만약 네트워크 통신 상황이라면? 개발자의 의도와는 다르게 많은 네트워크 콜이 들어갈 수 있다.
        /// share 메서드를 통해 Observable Stream을 공유할 수 있도록 처리해줄 수 있다.
        
        // let test = nextButton.rx.tap.map { "안녕하세요 \(Int.random(in: 1...100))" }
        // let test = nextButton.rx.tap.map { "안녕하세요 \(Int.random(in: 1...100))" }.share()
        // 
        // test
        //     .bind(to: nextButton.rx.title())
        //     .disposed(by: disposeBag)
        // 
        // test
        //     .bind(to: nicknameTextField.rx.text)
        //     .disposed(by: disposeBag)
        // 
        // test
        //     .bind(to: navigationItem.rx.title)
        //     .disposed(by: disposeBag)
        
            
        /// 그럼 Share를 안 쓰고 스트림을 공유할 수 있을까?
        /// subscribe에서 UI스럽게 bind로 왔다면
        /// 구독할 때 스트림을 공유하게 만들어주는 또 다른 친구가 있다
        /// -> Drive
        
        let test = nextButton
            .rx
            .tap
            .map { "안녕하세요 \(Int.random(in: 1...100))" }
            .asDriver(onErrorJustReturn: "")
        
        test
            .drive(nextButton.rx.title())
            .disposed(by: disposeBag)
        
        test
            .drive(nicknameTextField.rx.text)
            .disposed(by: disposeBag)
        
        test
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
    }
    
    func configureLayout() {
        view.addSubview(nicknameTextField)
        view.addSubview(nextButton)
         
        nicknameTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(nicknameTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
