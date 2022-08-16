//
//  LoginViewController.swift
//  CloudApp
//
//  Created by Timofey on 16/8/22.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewController: UIViewController {
  
  private enum Constants {
    static let topMarginMult: CGFloat = 0.145089285714286
    static let horizontalMarginMult: CGFloat = 0.12
    static let horizontalButtonMarginMult: CGFloat = 0.065
    static let buttonHeight: CGFloat = 60
  }
  
  private let bag = DisposeBag()
  
  private var welcomeLabel: UILabel!
  private var loginButton: StartScreenButton!
  private var loginTextField: SignUpTextField!
  private var passwordTextField: SignUpTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupButtonAction()
  }
  
  private func setupButtonAction() {
    loginButton
      .rx
      .tap
      .subscribe(onNext: { [weak self] _ in
        self?.tryLogin()
      })
      .disposed(by: bag)
  }
  
  private func loginUser(_ login: String, _ password: String) {
    AuthenticationService.shared.loginUser(
      email: login,
      password: password)
    { result in
      switch result {
      case .success(let user):
        UserDefaultsService.shared.saveUserId(user.uid)
        UpdateRootVCService.changeViewControllerPublisher.onNext(())
      case .failure(let error):
        AlertService.shared.errorAlertPublisher.accept(error.localizedDescription)
      }
    }
  }
  
  func tryLogin() {
    let login = loginTextField.text
    let password = passwordTextField.text
    
    let errors = Validator.isFilled(
      email: login,
      password: password,
      confirmPassword: password
    )
    if errors.count == 0 {
      loginUser(login, password)
    } else {
      for error in errors {
        switch error {
        case .email:
          loginTextField.twitch()
        case .password, .confirmPassword:
          passwordTextField.twitch()
        }
      }
    }
  }
  
}

// MARK: - SetupUI
extension LoginViewController {
  
  private func setupUI() {
    view.backgroundColor = .mainBg
    setupLabel()
    setupButton()
    setupTextField()
    setupConstraints()
  }
  
  private func setupButton() {
    loginButton = StartScreenButton(with: .light, title: "Login")
  }
  
  private func setupLabel() {
    welcomeLabel = UILabel(
      text: "Welcome back",
      fontSize: 31,
      weight: .bold,
      textColor: .white
    )
  }
  
  private func setupTextField() {
    loginTextField = SignUpTextField(type: .email)
    passwordTextField = SignUpTextField(type: .password)
  }
  
  private func setupConstraints() {
    
    let width = view.bounds.width
    let height = view.bounds.height
    
    view.addSubview(welcomeLabel)
    
    welcomeLabel.snp.makeConstraints { make in
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
        passwordTextField
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
    
    view.addSubview(loginButton)
    
    loginButton.snp.makeConstraints { make in
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

