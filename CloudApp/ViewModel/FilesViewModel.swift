//
//  FilesViewModel.swift
//  CloudApp
//
//  Created by Timofey on 15/8/22.
//

import Foundation
import Foundation

enum FilesViewModelEvent {
  case updateFilesViewModels(viewModels: [FileCellViewModel])
  case changeLayout(type: LayoutType)
  case showFileOptionsAlert(filename: String)
  case showRenameFileAlert(filename: String)
  case renameFileTouched(filename: String)
}

enum FilesViewEvent {
  case reloadFiles
  case viewLoaded
  case fileTouched(filename: String)
  case filterFiles(text: String)
  case downloadFileTouched(filename: String)
  case renameFileTouched(filename: String)
  case deleteFileTouched(filename: String)
  case showRenameFileAlert(filename: String)
  case renameFileApproved(oldFilename: String, newFilename: String)
}

class FilesListViewModel: ViewModel {
  
  typealias ViewEvent = FilesViewEvent
  typealias ViewModelEvent = FilesViewModelEvent
  
  private var storageService = StorageService()
  
  var output: Output<FilesViewModelEvent> = Output()
  
  private var foldername: String
  private var files: [FileCellViewModel] = []
  
  init(foldername: String = "") {
    self.foldername = foldername
  }
  
  func start() {
    storageService.filesDelegate = self
  }
  
  func handle(event: FilesViewEvent) {
    switch event {
    case .reloadFiles:
      storageService.fetchFiles(foldername: foldername)
    case .fileTouched(let filename):
      output.send(.showFileOptionsAlert(filename: filename))
    case .viewLoaded:
      storageService.fetchFiles(foldername: foldername)
    case .filterFiles(text: let text):
      filterFiles(with: text)
    case .downloadFileTouched(filename: let filename):
      print("download")
    case .renameFileTouched(filename: let filename):
      output.send(.showRenameFileAlert(filename: filename))
    case .deleteFileTouched(filename: let filename):
      print("delete")
    case .showRenameFileAlert(filename: let filename):
      output.send(.showRenameFileAlert(filename: filename))
    case .renameFileApproved(oldFilename: let oldFilename, newFilename: let newFilename):
      print("renaming file \(oldFilename) to \(newFilename)")
    }
  }
  
  func filterFiles(with text: String) {
    guard !text.isEmpty else {
      output.send(.updateFilesViewModels(viewModels: files))
      return
    }
    let filtered = files.filter { $0.filename.contains(text) }
    output.send(.updateFilesViewModels(viewModels: filtered))
  }
  
}

extension FilesListViewModel: StorageServiceFilesDelegate {
  
  func filesRecieved(_ files: [FileCellViewModel]) {
    self.files = files
    output.send(.updateFilesViewModels(viewModels: files))
  }
  
}
