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
}

enum FoldersViewEvent {
  case reloadFolders
  case folderTouched(foldername: String)
  case filterFolders(text: String)
  case viewLoaded
}


class FoldersViewModel: ViewModel {
  
  typealias ViewEvent = FoldersViewEvent
  typealias ViewModelEvent = FoldersViewModelEvent
  
  var output: Output<FoldersViewModelEvent> = Output()
  
  private var storageService = StorageService()
  private var folders: [FolderCellViewModel] = []
  
  init() {}
  
  func handle(event: ViewEvent) {
    switch event {
    case .reloadFolders:
      storageService.fetchFolders()
    case .folderTouched(foldername: let foldername):
      output.send(.openFolder(foldername: foldername))
    case .viewLoaded:
      storageService.fetchFolders()
    case .filterFolders(text: let text):
      filterFolders(with: text)
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
    storageService.foldersDelegate = self
    storageService.fetchFiles(foldername: "")
    storageService.fetchFolders()
  }
  
}

extension FoldersViewModel: StorageServiceFoldersDelegate {
  
  func foldersRecieved(_ folders: [FolderCellViewModel]) {
    self.folders = folders
    output.send(.updateFoldersViewModels(viewModels: folders))
  }
  
}
