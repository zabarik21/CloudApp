//
//  StorageService.swift
//  CollectionViewTest
//
//  Created by Timofey on 13/8/22.
//

import Foundation
import RxSwift


class StorageService {
  
  var files = [FileCellViewModel]()
  var folders = [FolderCellViewModel]()
  
  static let shared = StorageService()
  
  private let bag = DisposeBag()
  private var firebaseStorage = FirebaseStorageService.shared
  
  private init() {
    firebaseStorage.snapshotListener
      .subscribe(onNext: { [weak self] snapshot in
        self?.snapshot = snapshot
      })
      .disposed(by: bag)
  }
  
  private var snapshot: CloudFolder?
  
  weak var filesDelegate: StorageServiceFilesDelegate?
  weak var foldersDelegate: StorageServiceFoldersDelegate?
  
  func fetchFiles(foldername: String?) {
    
//    if let name = foldername {
//      firebaseStorage.fetchFilesFrom(foldername: name) { result in
//        switch result {
//        case .success(let items):
//          let viewModels = items.map { item in
//            return FileCellViewModel(filename: item.name, ext: item.ext)
//          }
//          self.filesDelegate?.filesRecieved(viewModels)
//        case .failure(let error):
//          print(error)
//        }
//      }
//    } else {
//
//    }
  }
 
  func fetchFolders() {
  }
  
  func loadFile(filename: String, folderName: String) {
    print("loading file \(filename)")
  }
}

protocol StorageServiceFoldersDelegate: AnyObject {
  func foldersRecieved(_ folders: [FolderCellViewModel])
}

protocol StorageServiceFilesDelegate: AnyObject {
  func filesRecieved(_ files: [FileCellViewModel])
}
