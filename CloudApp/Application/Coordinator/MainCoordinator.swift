//
//  MainCoordinator.swift
//  CloudApp
//
//  Created by Timofey on 22/8/22.
//

import Foundation
import UIKit

protocol MainCoordinatorProtocol: Coordinator {
  func switchToRootFolder()
}

class MainCoordinator: MainCoordinatorProtocol {
  
  var children = [Coordinator]()
  
  var nav: UINavigationController
  var authenticated: Bool = false
  
  init() {
    if UserDefaultsService.shared.getUserId() != nil {
      self.nav = RootFolderNavigationController()
      authenticated = true
    } else {
      self.nav = AuthenticationNavigationController()
      authenticated = false
    }
  }
  
  func start() {
    if authenticated {
      let folderCoordinator = RootFolderCoordinator(navigationController: self.nav)
      folderCoordinator.parent = self
      children.append(folderCoordinator)
      folderCoordinator.start()
    } else {
      let authCoordinator = AuthenticationCoordinator(navigationController: self.nav)
      authCoordinator.parent = self
      children.append(authCoordinator)
      authCoordinator.start()
    }
  }
  
  func switchToRootFolder() {
    children.removeFirst()
    authenticated = true
    let newNav = RootFolderNavigationController()
    self.nav = newNav
    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
      sceneDelegate.changeRootViewController(newNav)
    }
    let folderCoordinator = RootFolderCoordinator(navigationController: newNav)
    folderCoordinator.parent = self
    children.append(folderCoordinator)
    folderCoordinator.start()
  }
  
}
