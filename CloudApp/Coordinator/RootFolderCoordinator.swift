//
//  RootFolderCoordinator.swift
//  CloudApp
//
//  Created by Timofey on 22/8/22.
//

import Foundation
import UIKit

protocol RootFolderCoordinatorProtocol: Coordinator {
  func openFiles(with foldername: String, layoutType: LayoutType)
}

class RootFolderCoordinator: RootFolderCoordinatorProtocol {
 
  var children = [Coordinator]()
  weak var parent: Coordinator?
  
  var nav: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.nav = navigationController
  }
  
  func start() {
    DispatchQueue.main.async {
      let vc = MainFolderViewController()
      vc.coordinator = self
      self.nav.pushViewController(vc, animated: false)
    }
  }
  
  func openFiles(with foldername: String, layoutType: LayoutType) {
    DispatchQueue.main.async {
      let vc = FilesViewController(foldername: foldername, layoutType: layoutType)
      self.nav.pushViewController(vc, animated: true)
    }
  }
  
}
