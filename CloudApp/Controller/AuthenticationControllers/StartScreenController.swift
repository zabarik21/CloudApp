//
//  StartScreenController.swift
//  CloudApp
//
//  Created by Timofey on 16/8/22.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class StartScreenController: UIViewController {
  
  private enum Constants {
    static let topMarginMult: CGFloat = 0.246
    static let horizontalMarginMult: CGFloat = 0.212
    static let horizontalButtonMarginMult: CGFloat = 0.065
    static let buttonHeight: CGFloat = 60
  }
  
  private let bag = DisposeBag()
  
  private var logoImageView: UIImageView!
  private var loginButton: StartScreenButton!
  private var registerButton: StartScreenButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupButtonTargets()
  }
  
  private func setupButtonTargets() {
    loginButton
      .rx
      .tap
      .subscribe(onNext: { [weak self] _ in
        self?.navigationController?.pushViewController(LoginViewController(), animated: true)
      })
      .disposed(by: bag)
    
    registerButton
      .rx
      .tap
      .subscribe(onNext: { [weak self] _ in
        self?.navigationController?.pushViewController(SignUpController(), animated: true)
      })
      .disposed(by: bag)
  }
  
}

// MARK: - SetupUI
extension StartScreenController {
  
  private func setupUI() {
    view.backgroundColor = .mainBg
    setupLogo()
    setupButtons()
    setupConstraints()
  }
  
  private func setupConstraints() {
    
    let width = view.bounds.width
    let height = view.bounds.height
    
    view.addSubview(logoImageView)
    
    logoImageView.snp.makeConstraints { make in
      make.top
        .equalToSuperview()
        .offset(height * Constants.topMarginMult)
      make.horizontalEdges
        .equalToSuperview()
        .inset(width * Constants.horizontalMarginMult)
    }
    
    let buttonsStack = UIStackView(
      arrangedSubviews: [
        loginButton,
        registerButton
      ],
      spacing: 20,
      axis: .vertical,
      distribution: .equalSpacing,
      alignment: .fill
      )
    
    view.addSubview(buttonsStack)
    
    buttonsStack.snp.makeConstraints { make in
      make.horizontalEdges
        .equalToSuperview()
        .inset(Constants.horizontalButtonMarginMult * width)
      make.bottom
        .equalToSuperview()
        .offset(-50)
    }
    
    registerButton.snp.makeConstraints { make in
      make.height.equalTo(Constants.buttonHeight)
    }
    
    loginButton.snp.makeConstraints { make in
      make.height.equalTo(Constants.buttonHeight)
    }
  
  }
  
  private func setupButtons() {
    loginButton = StartScreenButton(with: .light, title: "Login")
    registerButton = StartScreenButton(with: .dark, title: "Register")
  }
  
  private func setupLogo() {
    logoImageView = UIImageView()
    logoImageView.image = UIImage(named: "logo")
    logoImageView.contentMode = .scaleAspectFit
  }
  
}

