//
//  FilesViewModel.swift
//  CloudApp
//
//  Created by Timofey on 15/8/22.
//

import Foundation
import PhotosUI

enum FilesViewModelEvent {
  case updateFilesViewModels(viewModels: [FileCellViewModel])
  case changeLayout(type: LayoutType)
  case showFileOptionsAlert(filename: String)
  case showRenameFileAlert(filename: String)
  case showErrorAlert(message: String)
  case showDefaultAlert(title: String, message: String)
  case renameFileTouched(filename: String)
}

enum FilesViewEvent {
  case reloadFiles
  case viewLoaded
  case addFromGallery(result: PHPickerResult)
  case addFromFiles(url: URL)
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
  
  private var storageService = FirebaseStorageService.shared
  
  var output: Output<FilesViewModelEvent> = Output()
  
  private var foldername: String?
  private var files: [FileCellViewModel] = []
  
  init(foldername: String? = nil) {
    self.foldername = foldername
  }
  
  func start() {
    
  }
  
  func fetchFiles() {
    storageService.fetchFilesFrom(
      foldername: foldername) { result in
        switch result {
        case .success(let items):
          let viewModels = items.map { item in
            FileCellViewModel(filename: item.name)
          }
          self.files = viewModels
          self.output.send(.updateFilesViewModels(viewModels: viewModels))
        case .failure(let error):
          print(error)
        }
      }
  }
  
  func handle(event: FilesViewEvent) {
    switch event {
    case .reloadFiles:
      fetchFiles()
    case .fileTouched(let filename):
      output.send(.showFileOptionsAlert(filename: filename))
    case .viewLoaded:
      fetchFiles()
    case .filterFiles(text: let text):
      filterFiles(with: text)
    case .downloadFileTouched(filename: let filename):
      downloadFile(filename)
    case .renameFileTouched(filename: let filename):
      output.send(.showRenameFileAlert(filename: filename))
    case .deleteFileTouched(filename: let filename):
      self.deleteFile(filename)
    case .showRenameFileAlert(filename: let filename):
      output.send(.showRenameFileAlert(filename: filename))
    case .renameFileApproved(oldFilename: let oldFilename, newFilename: let newFilename):
      renameFile(old: oldFilename, new: newFilename)
    case .addFromGallery(result: let result):
      self.addFromGallery(result)
    case .addFromFiles(url: let url):
      addFromFiles(fileUrl: url)
    }
  }
  
  private func deleteFile(_ filename: String) {
    storageService.deleteFile(
      filename: filename,
      foldername: self.foldername) { result in
        switch result {
        case .success:
          self.files.removeAll(where: { $0.filename == filename })
          self.output.send(.updateFilesViewModels(viewModels: self.files))
          self.output.send(.showDefaultAlert(title: "Success", message: "Deleted file \(filename)"))
        case .failure(let error):
          self.output.send(.showErrorAlert(message: error.localizedDescription))
        }
      }
  }
  
  private func downloadFile(_ filename: String) {
    storageService.loadDataFromStorage(filename: filename, folderName: foldername) { result in
      switch result {
      case .success:
        let folderString = self.foldername == nil ? "" : "/\(self.foldername!)"
        let savedToString = "File \(filename) saved to \(folderString) folder in your phone"
        self.output.send(.showDefaultAlert(title: "Success", message: savedToString))
      case .failure(let error):
        self.output.send(.showErrorAlert(message: error.localizedDescription))
      }
    }
  }
  
  private func renameFile(old: String, new: String) {
    guard let index = files.firstIndex(where: { $0.filename == old }) else {
      output.send(.showErrorAlert(message: "File named \(new) doesnt exist"))
      return
    }
    storageService.renameFile(new, oldFilename: old, foldername: foldername) { result in
      switch result {
      case .success:
        self.files[index].filename = new
        self.output.send(.updateFilesViewModels(viewModels: self.files))
        self.output.send(.showDefaultAlert(title: "Success", message: "File \(old) renamed to \(new)"))
      case .failure(let error):
        self.output.send(.showErrorAlert(message: error.localizedDescription))
      }
    }
  }
  
  private func addFromFiles(fileUrl: URL) {
    storageService.uploadDataToStorage(fileUrl, folderName: self.foldername) { result in
      switch result {
      case .success(let filename):
        guard !self.files.contains(where: {  $0.filename == filename }) else {
          self.output.send(.showErrorAlert(message: "File already exists"))
          return
        }
        self.files.append(FileCellViewModel(filename: filename))
        self.output.send(.updateFilesViewModels(viewModels: self.files))
      case .failure(let error):
        self.output.send(.showErrorAlert(message: error.localizedDescription))
      }
    }
  }
  
  private func addFromGallery(_ results: PHPickerResult) {
    storageService.uploadMediaToStorage(result: results) { result in
      switch result {
      case .success(let filename):
        guard !self.files.contains(where: { $0.filename == filename }) else {
          self.output.send(.showErrorAlert(message: "File already exists"))
          return
        }
        self.files.append(FileCellViewModel(filename: filename))
        self.output.send(.updateFilesViewModels(viewModels: self.files))
      case .failure(let error):
        self.output.send(.showErrorAlert(message: error.localizedDescription))
      }
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
