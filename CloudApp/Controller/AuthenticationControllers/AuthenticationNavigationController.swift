//
//  AuthenticationNavigationController.swift
//  CloudApp
//
//  Created by Timofey on 16/8/22.
//

import Foundation
import UIKit
import RxSwift


class AuthenticationNavigationController: UINavigationController {
  
  private let bag = DisposeBag()
  
  init() {
    super.init(rootViewController: StartScreenController())
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupAlerts()
    setupSwitchViewControllerObservable()
  }
  
  private func setupSwitchViewControllerObservable() {
    UpdateRootVCService.shared.chagneViewControllerObservable
      .subscribe(onNext: { [weak self] _ in
        self?.switchToRootFolderViewController()
      })
      .disposed(by: bag)
  }
  
  func switchToRootFolderViewController() {
    DispatchQueue.main.async {
      if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
        let rootFolderViewControlelr = MainFolderNavigationController()
        sceneDelegate.changeRootViewController(rootFolderViewControlelr, animated: true)
      }
    }
  }
  
  private func setupAlerts() {
    AlertService.shared.alertObservable
      .subscribe(onNext: { [weak self] alertInfo in
        DispatchQueue.main.async {
          let alert = AlertFactory.getMessageAlert(
            title: alertInfo.title,
            message: alertInfo.message
          )
          self?.present(alert, animated: true)
        }
      })
      .disposed(by: bag)
    
    AlertService.shared.errorAlertPublisher
      .subscribe(onNext: { [weak self] message in
        DispatchQueue.main.async {
          let errorAlert = AlertFactory.getErrorAlert(message: message)
          self?.present(errorAlert, animated: true)
        }
      })
      .disposed(by: bag)
  }
  
  private func setupNavigationBar() {
    navigationBar.tintColor = .white
    navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationBar.shadowImage = UIImage()
    navigationBar.isTranslucent = true
    view.backgroundColor = .mainBg
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
