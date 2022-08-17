//
//  AlertFactory.swift
//  CollectionViewTest
//
//  Created by Timofey on 15/8/22.
//

import Foundation
import UIKit


class AlertFactory {
  
  static func getMessageAlert(
    title: String,
    message: String
  ) -> UIAlertController {
    let alertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: "Ok",
        style: .default
      )
    )
    return alertController
  }
  
  static func getFilesActionAlert(
    filename: String,
    downloadAction: @escaping () -> (),
    renameAction: @escaping () -> (),
    deleteAction: @escaping () -> ()
  ) -> UIAlertController {
    let alertController = UIAlertController(
      title: filename,
      message: "Options",
      preferredStyle: .alert
    )
    let downloadAction = UIAlertAction(
      title: "Download",
      style: .default
    ) { _ in
        downloadAction()
      }
    let renameAction = UIAlertAction(
      title: "Rename",
      style: .default) { _ in
        renameAction()
      }
    let deleteAction = UIAlertAction(
      title: "Delete",
      style: .destructive
    ) { _ in
        deleteAction()
      }
    let cancelAction = UIAlertAction(
      title: "Cancel",
      style: .destructive
    )
    for action in [downloadAction, renameAction, deleteAction, cancelAction] {
      alertController.addAction(action)
    }
    return alertController
  }
  
  static func getErrorAlert(
    title: String = "Error",
    message: String
  ) -> UIAlertController {
    let alertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: "Ok",
        style: .default
      )
    )
    return alertController
  }
  
  static func getCreateFolderAlert(
    createAction: @escaping (_ folderName: String) -> ()
  ) -> UIAlertController {
    let alertController = UIAlertController(
      title: "Create folder",
      message: "Input folder name",
      preferredStyle: .alert
    )
    
    alertController.addTextField(configurationHandler: nil)
    
    let createAction = UIAlertAction(
      title: "Create",
      style: .default
    ) { _ in
      guard let text = alertController.textFields![0].text else { return }
        createAction(text)
      }
    let cancelAction = UIAlertAction(
      title: "Cancel",
      style: .destructive
    )
    alertController.addAction(createAction)
    alertController.addAction(cancelAction)
    
    return alertController
  }
  
  static func getRenameFileAlert(
    renameAction: @escaping (_ folderName: String) -> ()
  ) -> UIAlertController {
    let alertController = UIAlertController(
      title: "Rename file",
      message: "Input new file name",
      preferredStyle: .alert
    )
    
    alertController.addTextField(configurationHandler: nil)
    
    let createAction = UIAlertAction(
      title: "Create",
      style: .default
    ) { _ in
      guard let text = alertController.textFields![0].text else { return }
        renameAction(text)
      }
    let cancelAction = UIAlertAction(
      title: "Cancel",
      style: .destructive
    )
    alertController.addAction(createAction)
    alertController.addAction(cancelAction)
    
    return alertController
  }
  
}
