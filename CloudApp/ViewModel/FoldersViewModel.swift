//
//  RootFolderViewModel.swift
//  CollectionViewTest
//
//  Created by Timofey on 14/8/22.
//

import Foundation


enum FoldersViewModelEvent {
  case updateFoldersViewModels(viewModels: [FolderCellViewModel])
  case openFolder(foldername: String)
  case showAlert(title: String, message: String)
  case startActivityIndicator
  case scrollToFolder(foldername: String)
  case stopActivityIndicator
}

enum FoldersViewEvent {
  case reloadFolders
  case folderTouched(foldername: String)
  case createFolder(foldername: String)
  case filterFolders(text: String)
  case viewLoaded
}


class FoldersViewModel: ViewModel {
  
  typealias ViewEvent = FoldersViewEvent
  typealias ViewModelEvent = FoldersViewModelEvent
  
  var output: Output<FoldersViewModelEvent> = Output()
  
  private var storageService = FirebaseStorageService.shared
  private var folders: [FolderCellViewModel] = []
  
  init() {}
  
  func fetchFolders() {
    output.send(.startActivityIndicator)
    storageService.fetchFolders { result in
      switch result {
      case .success(let folders):
        self.folders = folders
        self.output.send(.updateFoldersViewModels(viewModels: folders))
      case .failure(let error):
        self.output.send(.showAlert(title: "Error", message: error.localizedDescription))
      }
      self.output.send(.stopActivityIndicator)
    }
  }
  
  func handle(event: ViewEvent) {
    switch event {
    case .reloadFolders:
      fetchFolders()
    case .folderTouched(foldername: let foldername):
      output.send(.openFolder(foldername: foldername))
    case .viewLoaded:
      fetchFolders()
    case .filterFolders(text: let text):
      filterFolders(with: text)
    case .createFolder(foldername: let foldername):
      createFolder(with: foldername)
  }
  

  
  }
  
  func createFolder(with foldername: String) {
    guard !folders.contains(where: { $0.name == foldername }) else {
      output.send(.showAlert(title: "Error", message: "Folder already exists"))
      return
    }
    output.send(.startActivityIndicator)
    storageService.createFolder(foldername: foldername) { result in
      switch result {
      case .success:
        self.folders.append(FolderCellViewModel(name: foldername, objectsCount: 1))
        self.output.send(.updateFoldersViewModels(viewModels: self.folders))
        self.output.send(.scrollToFolder(foldername: foldername))
      case .failure(let error):
        self.output.send(.showAlert(title: "Cant create folder", message: error.localizedDescription))
      }
      self.output.send(.stopActivityIndicator)
    }
  }
  
  func filterFolders(with text: String) {
    guard !text.isEmpty else {
      output.send(.updateFoldersViewModels(viewModels: folders))
      return
    }
    let filtered = folders.filter { $0.name.contains(text) }
    output.send(.updateFoldersViewModels(viewModels: filtered))
  }
  
  func start() {
//    storageService.foldersDelegate = self
//    storageService.fetchFiles(foldername: "")
//    storageService.fetchFolders()
  }
  
}
