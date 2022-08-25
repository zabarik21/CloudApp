//
//  AuthenticationCoordinator.swift
//  CloudApp
//
//  Created by Timofey on 22/8/22.
//

import Foundation
import UIKit

protocol AuthenticationCoordinatorProtocol: Coordinator {
  func openLogin()
  func openSignUp()
  func loginUser()
}

class AuthenticationCoordinator: AuthenticationCoordinatorProtocol {
  
  var children = [Coordinator]()
  weak var parent: MainCoordinatorProtocol?
  var nav: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.nav = navigationController
  }
  
  func start() {
    DispatchQueue.main.async {
      let vc = AuthenticationController()
      vc.coordinator = self
      self.nav.pushViewController(vc, animated: false)
    }
  }
  
  func openLogin() {
    DispatchQueue.main.async {
      let login = LoginViewController()
      login.coordinator = self
      self.nav.pushViewController(login, animated: true)
    }
  }
  
  func openSignUp() {
    DispatchQueue.main.async {
      let signup = SignUpController()
      signup.coordinator = self
      self.nav.pushViewController(signup, animated: true)
    }
  }
  
  func loginUser() {
    parent?.switchToRootFolder()
  }
  
}
