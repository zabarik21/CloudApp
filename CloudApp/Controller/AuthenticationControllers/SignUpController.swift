//
//  SignUpController.swift
//  CloudApp
//
//  Created by Timofey on 16/8/22.
//

import Foundation


import RxCocoa
import RxSwift

class SignUpController: UIViewController {
  
  private enum Constants {
    static let topMarginMult: CGFloat = 0.145089285714286
    static let horizontalMarginMult: CGFloat = 0.12
    static let horizontalButtonMarginMult: CGFloat = 0.065
    static let buttonHeight: CGFloat = 60
  }
  
  private let bag = DisposeBag()
  private var changeRootViewControllerPublisher = PublishSubject<Void>()
  
  private var singUpLabel: UILabel!
  private var signupButton: StartScreenButton!
  private var loginTextField: SignUpTextField!
  private var passwordTextField: SignUpTextField!
  private var confirmPasswordTextField: SignUpTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupButtonAction()
  }
  
  private func setupButtonAction() {
    signupButton
      .rx
      .tap
      .subscribe(onNext: { [weak self] _ in
        self?.trySignUp()
      })
      .disposed(by: bag)
  }
  
  private func signupUser(_ login: String, _ password: String) {
    AlertService.shared.alertPublisher.accept(
      (
        title: "Wait",
        message: "You will be registered in a second"
      )
    )
    DispatchQueue.global(qos: .userInteractive).async {
      AuthenticationService.shared.registerUser(
        email: login,
        password: password) { result in
          switch result {
          case .success(let user):
            UserDefaultsService.shared.saveUserId(user.uid)
            UpdateRootVCService.shared.changeViewControllerPublisher.accept(())
          case .failure(let error):
            AlertService.shared.errorAlertPublisher.accept(
              error.localizedDescription
            )
          }
        }
    }
  }
  
  func trySignUp() {
    let login = loginTextField.text
    let password = passwordTextField.text
    let confirm = confirmPasswordTextField.text
    
    let errors = Validator.isFilled(
      email: login,
      password: password,
      confirmPassword: confirm
    )
    if errors.count == 0 {
      signupUser(login, password)
    } else {
      for error in errors {
        switch error {
        case .email:
          loginTextField.twitch()
        case .password:
          passwordTextField.twitch()
        case .confirmPassword:
          confirmPasswordTextField.twitch()
        }
      }
    }
  }
  
}

// MARK: - SetupUI
extension SignUpController {
  
  private func setupUI() {
    setupLabel()
    setupButton()
    setupTextField()
    setupConstraints()
  }
  
  private func setupButton() {
    signupButton = StartScreenButton(with: .dark, title: "Sign Up")
  }
  
  private func setupLabel() {
    singUpLabel = UILabel(
      text: "Sign up",
      fontSize: 31,
      weight: .bold,
      textColor: .white
    )
  }
  
  private func setupTextField() {
    loginTextField = SignUpTextField(type: .email)
    passwordTextField = SignUpTextField(type: .password)
    confirmPasswordTextField = SignUpTextField(type: .confirmPassword)
  }
  
  private func setupConstraints() {
    
    let width = view.bounds.width
    let height = view.bounds.height
    
    view.addSubview(singUpLabel)
    
    singUpLabel.snp.makeConstraints { make in
      make.horizontalEdges
        .equalToSuperview()
        .offset(Constants.horizontalButtonMarginMult * width)
      make.top
        .equalToSuperview()
        .offset(Constants.topMarginMult * height)
    }
    
    let textFieldsStack = UIStackView(
      arrangedSubviews: [
        loginTextField,
        passwordTextField,
        confirmPasswordTextField
      ],
      spacing: 20,
      axis: .vertical,
      distribution: .equalSpacing,
      alignment: .fill
    )
    
    view.addSubview(textFieldsStack)
    
    textFieldsStack.snp.makeConstraints { make in
      make.horizontalEdges
        .equalToSuperview()
        .inset(Constants.horizontalMarginMult * width)
      make.centerY.equalToSuperview()
    }
    
    view.addSubview(signupButton)
    
    signupButton.snp.makeConstraints { make in
      make.height.equalTo(Constants.buttonHeight)
      make.horizontalEdges
        .equalToSuperview()
        .inset(Constants.horizontalButtonMarginMult * width)
      make.bottom
        .equalToSuperview()
        .offset(-50)
    }
  }
  
}

