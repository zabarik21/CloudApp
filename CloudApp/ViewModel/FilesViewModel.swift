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
  case startActivityIndicator
  case stopActivityIndicator
  case changeLayout(type: LayoutType)
  case showFileOptionsAlert(filename: String)
  case showRenameFileAlert(filename: String)
  case showErrorAlert(message: String)
  case showDefaultAlert(title: String, message: String)
}

enum FilesViewEvent {
  case reloadFiles
  case viewLoaded
  case createFolderTouched
  case addFromGallery(result: PHPickerResult)
  case addFromFiles(url: URL)
  case filterFiles(text: String)
  case fileTouchedAt(indexPath: IndexPath)
  case downloadFileTouchedAt
  case deleteFileTouchedForItemAt
  case renameFileTouched
  case renameFileApprovedForItemAt(newFilename: String)
}

class FilesListViewModel: ViewModel {
  
  typealias ViewEvent = FilesViewEvent
  typealias ViewModelEvent = FilesViewModelEvent
  
  private var storageService: FilesServiceProtocol = FirebaseStorageService.shared
  private var selectedIndexPath = IndexPath()
  
  var output: Output<FilesViewModelEvent> = Output()
  
  private var foldername: String?
  private var files: [FileCellViewModel] = [] {
    didSet {
      self.filteredFiles = files
    }
  }
  private var filteredFiles: [FileCellViewModel] = []
  
  init(foldername: String? = nil) {
    self.foldername = foldername
  }
  
  func start() {
    
  }
  
  func fetchFiles() {
    output.send(.startActivityIndicator)
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
          self.output.send(.showErrorAlert(message: error.localizedDescription))
        }
        self.output.send(.stopActivityIndicator)
      }
  }
  
  private func handleFileTouchAt(_ indexPath: IndexPath) {
    guard let filename = getFileName(for: indexPath) else { return }
    selectedIndexPath = indexPath
    output.send(.showFileOptionsAlert(filename: filename))
  }
  
  private func handleRenameFileTouch() {
    guard let filename = getFileName(for: selectedIndexPath) else { return }
    output.send(.showRenameFileAlert(filename: filename))
  }
  
  func handle(event: FilesViewEvent) {
    switch event {
    case .reloadFiles:
      fetchFiles()
    case .fileTouchedAt(let indexPath):
      handleFileTouchAt(indexPath)
    case .viewLoaded:
      fetchFiles()
    case .filterFiles(let text):
      filterFiles(with: text)
    case .downloadFileTouchedAt:
      tryDownloadFileAtIndexPath()
    case .renameFileTouched:
      handleRenameFileTouch()
    case .deleteFileTouchedForItemAt:
      tryDeleteFile()
    case .renameFileApprovedForItemAt(let newFilename):
      tryRenameFile(newName: newFilename)
    case .addFromGallery(let result):
      self.tryAddFromPhotos(result)
    case .addFromFiles(let url):
      tryAddFromFiles(fileUrl: url)
    case .createFolderTouched:
      output.send(.showErrorAlert(message: "Cant create folder inside a folder"))
    }
  }
  
  private func tryDeleteFile() {
    guard let filename = getFileName(for: selectedIndexPath) else { return }
    output.send(.startActivityIndicator)
    storageService.deleteFile(
      filename: filename,
      foldername: self.foldername) { result in
        switch result {
        case .success:
          self.deleteFileSucceed(with: filename)
        case .failure(let error):
          self.output.send(.showErrorAlert(message: error.localizedDescription))
        }
        self.output.send(.stopActivityIndicator)
      }
  }
  
  private func deleteFileSucceed(with filename: String) {
    files.removeAll(where: { $0.filename == filename })
    output.send(.updateFilesViewModels(viewModels: self.files))
    output.send(.showDefaultAlert(title: "Success", message: "Deleted file \(filename)"))
  }
  
  private func tryDownloadFileAtIndexPath() {
    output.send(.startActivityIndicator)
    guard let filename = getFileName(for: selectedIndexPath) else { return }
    storageService.loadDataFromStorage(filename: filename, folderName: foldername) { result in
      switch result {
      case .success:
        self.showSuccessDownloadAlert(filename: filename)
      case .failure(let error):
        self.output.send(.showErrorAlert(message: error.localizedDescription))
      }
      self.output.send(.stopActivityIndicator)
    }
  }
  
  private func showSuccessDownloadAlert(filename: String) {
    let folderString = self.foldername == nil ? "" : "/\(self.foldername!)"
    let savedToString = "File \(filename) saved to CloudApp\(folderString) folder in your Files app"
    self.output.send(.showDefaultAlert(title: "Success", message: savedToString))
  }
  
  private func tryRenameFile(newName: String) {
    guard let oldFilename = getFileName(for: selectedIndexPath) else {
      return
    }
    output.send(.startActivityIndicator)
    storageService.renameFile(newName, oldFilename: oldFilename, foldername: foldername) { result in
      switch result {
      case .success:
        self.renameFile(oldFilename: oldFilename, newFilename: newName)
      case .failure(let error):
        self.output.send(.showErrorAlert(message: error.localizedDescription))
      }
      self.output.send(.stopActivityIndicator)
    }
  }
  
  private func renameFile(oldFilename: String, newFilename: String) {
    guard let filesIndex = files.firstIndex(where: { $0.filename == oldFilename }) else { return }
    files[filesIndex].filename = newFilename
    filteredFiles[selectedIndexPath.row].filename = newFilename
    output.send(.updateFilesViewModels(viewModels: self.files))
    output.send(.showDefaultAlert(title: "Success", message: "File \(oldFilename) renamed to \(newFilename)"))
  }
  
  private func tryAddFromFiles(fileUrl: URL) {
    output.send(.startActivityIndicator)
    storageService.uploadDataToStorage(fileUrl, folderName: self.foldername) { result in
      switch result {
      case .success(let filename):
        self.addNewFile(filename: filename)
      case .failure(let error):
        self.output.send(.showErrorAlert(message: error.localizedDescription))
      }
      self.output.send(.stopActivityIndicator)
    }
  }
  
  private func tryAddFromPhotos(_ results: PHPickerResult) {
    output.send(.startActivityIndicator)
    storageService.uploadMediaToStorage(result: results, foldername: self.foldername) { result in
      switch result {
      case .success(let filename):
        self.addFromPhotos(filename: filename)
      case .failure(let error):
        self.output.send(.showErrorAlert(message: error.localizedDescription))
      }
      self.output.send(.stopActivityIndicator)
    }
  }
  
  private func addFromPhotos(filename: String) {
    guard !files.contains(where: { $0.filename == filename }) else {
      self.output.send(.showErrorAlert(message: "File already exists"))
      return
    }
    files.append(FileCellViewModel(filename: filename))
    output.send(.updateFilesViewModels(viewModels: self.files))
  }
  
  private func addNewFile(filename: String) {
    guard !files.contains(where: {  $0.filename == filename }) else {
      self.output.send(.showErrorAlert(message: "File already exists"))
      return
    }
    files.append(FileCellViewModel(filename: filename))
    output.send(.updateFilesViewModels(viewModels: self.files))
  }
  
  func filterFiles(with text: String) {
    guard !text.isEmpty else {
      output.send(.updateFilesViewModels(viewModels: files))
      return
    }
    filteredFiles = files.filter { $0.filename.contains(text) }
    output.send(.updateFilesViewModels(viewModels: filteredFiles))
  }
  
  private func getFileName(for indexPath: IndexPath) -> String? {
    let index = indexPath.row
    guard filteredFiles.count > index else { return nil }
    return filteredFiles[index].filename
  }
  
}

