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
  case folderTouchedAt(indexPath: IndexPath)
  case createFolder(foldername: String)
  case filterFolders(text: String)
  case viewLoaded
}


class FoldersViewModel: ViewModel {
  
  typealias ViewEvent = FoldersViewEvent
  typealias ViewModelEvent = FoldersViewModelEvent
  
  var output: Output<FoldersViewModelEvent> = Output()
  
  private var selectedIndexPath = IndexPath()
  
  private var storageService: FolderServiceProtocol = FirebaseStorageService.shared
  private var folders = [FolderCellViewModel]() {
    didSet {
      filteredFolders = folders
    }
  }
  private var filteredFolders = [FolderCellViewModel]()
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
    case .folderTouchedAt(let indexPath):
      handleFolderTouch(with: indexPath)
    case .viewLoaded:
      fetchFolders()
    case .filterFolders(text: let text):
      filterFolders(with: text)
    case .createFolder(foldername: let foldername):
      tryCreateFolder(with: foldername)
    }
  }
 
  private func handleFolderTouch(with indexPath: IndexPath) {
    guard let foldername = getFoldername(indexPath: indexPath) else { return }
    output.send(.openFolder(foldername: foldername))
  }
  
  private func tryCreateFolder(with foldername: String) {
    guard !folders.contains(where: { $0.name == foldername }) else {
      output.send(.showAlert(title: "Error", message: "Folder already exists"))
      return
    }
    output.send(.startActivityIndicator)
    storageService.createFolder(foldername: foldername) { result in
      switch result {
      case .success:
        self.createFolder(with: foldername)
      case .failure(let error):
        self.output.send(.showAlert(title: "Cant create folder", message: error.localizedDescription))
      }
      self.output.send(.stopActivityIndicator)
    }
  }
  
  private func createFolder(with foldername: String) {
    folders.append(FolderCellViewModel(name: foldername, objectsCount: 1))
    output.send(.updateFoldersViewModels(viewModels: self.folders))
    output.send(.scrollToFolder(foldername: foldername))
  }
  
  func filterFolders(with text: String) {
    guard !text.isEmpty else {
      output.send(.updateFoldersViewModels(viewModels: folders))
      return
    }
    filteredFolders = folders.filter { $0.name.contains(text) }
    output.send(.updateFoldersViewModels(viewModels: filteredFolders))
  }
  
  private func getFoldername(indexPath: IndexPath) -> String? {
    guard indexPath.row < filteredFolders.count else { return nil }
    return filteredFolders[indexPath.row].name
  }
  
  func start() {}
  
}

