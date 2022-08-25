//
//  UIViewController + UIAlertController.swift
//  CloudApp
//
//  Created by Timofey on 18/8/22.
//

import Foundation
import UIKit

extension UIViewController {
  
  func showErrorAlert(_ message: String) {
    DispatchQueue.main.async {
      let alert = AlertFactory.getErrorAlert(message: message)
      self.present(alert, animated: true)
    }
  }
  
  func showDefaultAlert(_ title: String, _ message: String) {
    DispatchQueue.main.async {
      let alert = AlertFactory.getMessageAlert(title: title, message: message)
      self.present(alert, animated: true)
    }
  }
  
}
