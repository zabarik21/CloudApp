//
//  MainFolderRouter.swift
//  CloudApp
//
//  Created by Timofey on 25/8/22.
//

import Foundation
import UIKit
import UniformTypeIdentifiers
import Photos
import PhotosUI

protocol MainFolderRouterProtocol {
  var view: MainFolderViewProtocol { get }
  func presentPhotos()
  func presentFiles()
}

class MainFolderRouter: MainFolderRouterProtocol {
  unowned var view: MainFolderViewProtocol
  
  init(_ view: MainFolderViewProtocol) {
    self.view = view
  }
  
  func presentPhotos() {
    var config = PHPickerConfiguration(photoLibrary: .shared())
    config.selectionLimit = 1
    config.filter = .any(of: [.images, .videos])
    let picker = PHPickerViewController(configuration: config)
    picker.delegate = view
    view.present(picker, animated: true)
  }
  
  func presentFiles() {
    let pickerViewController = UIDocumentPickerViewController(
      forOpeningContentTypes: UTType.allUTITypes()
    )
    pickerViewController.delegate = view
    pickerViewController.allowsMultipleSelection = false
    view.present(pickerViewController, animated: true)
  }
  
}
