//
//  StorageService.swift
//  StorageTest
//
//  Created by Timofey on 10/8/22.
//

import Foundation
import FirebaseStorage
import PhotosUI
import RxSwift

final class FirebaseStorageService: FolderServiceProtocol, FilesServiceProtocol {
  
  private enum Constants {
    static let usersPath = "users"
    static let hiddenFileName = "12c8f301-50ea-4a38-b2ca-1f4b424da6cd.txt"
  }
  
  static let shared = FirebaseStorageService()
  private init() {}
  
  private let filesService = FileManagerService.shared
  private let authService = AuthenticationService.shared
  
  private let loadTasksQueue = DispatchQueue(
    label: "tasksQueue",
    qos: .utility,
    attributes: .concurrent
  )
  private let fetchFilesQuque = DispatchQueue.global(qos: .utility)
  private let fetchFolderQueue = DispatchQueue.global(qos: .utility)
  
  private var currentUserID: String {
    return AuthenticationService.shared.getCurrentUserId() ?? "default"
  }
  
  private let storageRef = Storage.storage().reference()
  
  func deleteFile(
    filename: String,
    foldername: String?,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    loadTasksQueue.async { [weak self] in
      guard let self = self else { return }
      guard filename != Constants.hiddenFileName else {
        completion(.failure(FirebaseStorageError.nonEnoughRights))
        return
      }
      let ref = self.getReference(fileName: filename, folderName: foldername)
      ref.delete { error in
        if let error = error {
          completion(.failure(error))
        } else {
          completion(.success(()))
        }
      }
    }
  }
  
  func renameFile(
    _ newName: String,
    oldFilename: String,
    foldername: String?,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard oldFilename != Constants.hiddenFileName else {
      completion(.failure(FirebaseStorageError.nonEnoughRights))
      return
    }
    loadTasksQueue.async { [weak self] in
      guard let self = self else { return }
      let ref = self.getReference(fileName: oldFilename, folderName: foldername)
      let newRef = self.getReference(fileName: newName, folderName: foldername)
      ref.getData(maxSize: 20000000) { data, error in
        if let error = error {
          completion(.failure(error))
          return
        }
        guard let data = data else { return }
        newRef.putData(data, metadata: nil) { result in
          switch result {
          case .success:
            self.deleteFile(filename: oldFilename, foldername: foldername) { result in
              switch result {
              case .success:
                completion(.success(()))
              case .failure(let error):
                print(error)
              }
            }
          case .failure(let error):
            completion(.failure(error))
            return
          }
        }
      }
    }
  }
  
  func loadDataFromStorage(
    filename: String,
    folderName: String?,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    let ref = getReference(fileName: filename, folderName: folderName)
    loadTasksQueue.async { [weak self] in
      guard let self = self else { return }
      ref.getData(maxSize: 20000000) { data, error in
        if let error = error {
          completion(.failure(error))
        }
        guard let data = data else {
          completion(.failure(FirebaseStorageError.nilData))
          return
        }
        self.filesService.saveToFiles(
          data: data,
          filename: filename,
          foldername: folderName) { result in
            switch result {
            case .success:
              completion(.success(()))
            case .failure(let error):
              completion(.failure(error))
            }
          }
      }
    }
  }
  
  func fetchFolders(
    completion: @escaping (Result<[FolderCellViewModel], Error>) -> Void
  ) {
    let rootRef = getReference(fileName: "", folderName: nil)
    fetchFolderQueue.async {
      rootRef.listAll { result in
        switch result {
        case .success(let storageListResult):
          let folders = storageListResult.prefixes.map { ref in
            FolderCellViewModel(name: ref.name, objectsCount: 1)
          }
          completion(.success(folders))
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }
  
  func fetchFilesFrom(
    foldername: String?,
    completion: @escaping (Result<[CloudItem], Error>) -> Void
  ) {
    let ref = getReference(fileName: nil, folderName: foldername)
    fetchFilesQuque.async { [weak self] in
      self?.fetchFilesFrom(ref) { result in
        switch result {
        case .success(let items):
          let hidedFileItems = items.filter { $0.name != Constants.hiddenFileName }
          completion(.success(hidedFileItems))
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }
  
  private func fetchFilesFrom(
    _ reference: StorageReference,
    completion: @escaping (Result<[CloudItem], Error>) -> Void
  ) {
    var items = [CloudItem]()
    fetchFolderQueue.async {
      let group = DispatchGroup()
      group.enter()
      reference.listAll { result in
        defer { group.leave() }
        switch result {
        case .success(let storageListResult):
          for item in storageListResult.items {
            guard item.name != Constants.hiddenFileName else { continue }
            items.append(CloudItem(name: item.name, path: item.fullPath))
          }
          completion(.success(items))
        case .failure(let error):
          completion(.failure(error))
        }
      }
      DispatchQueue.global().async {
        group.wait()
      }
    }
  }
  
  func uploadDataToStorage(
    _ url: URL?,
    folderName: String?,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    guard let url = url else {
      completion(.failure(DataError.invalidDataURL))
      return
    }
    
    let name = url.lastPathComponent
    let ref = getReference(fileName: name, folderName: folderName)
    let metadata = StorageMetadata()
    
    fetchFilesQuque.async { [weak self] in
      self?.filesService.getData(from: url) { result in
        switch result {
        case .success(let data):
          ref.putData(data, metadata: metadata) { result in
            switch result {
            case .success(let metadata):
              print(metadata)
              completion(.success(name))
            case .failure(let error):
              print(error)
              completion(.failure(error))
            }
          }
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }
  
  func createFolder(
    foldername: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    let ref = getReference(fileName: Constants.hiddenFileName, folderName: foldername)
    fetchFolderQueue.async {
      ref.putData(.hiddenFileData, metadata: nil) { result in
        switch result {
        case .success:
          completion(.success(()))
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }
  
  func uploadDataToStorage(
    _ data: Data?,
    folderName: String?,
    fileName: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard let data = data else {
      completion(.failure(DataError.nilData))
      return
    }
    
    let ref = getReference(fileName: fileName, folderName: folderName)
    let metadata = StorageMetadata()
    
    fetchFilesQuque.async {
      ref.putData(data, metadata: metadata) { result in
        switch result {
        case .success(let metadata):
          print(metadata)
          completion(.success(()))
        case .failure(let error):
          print(error)
          completion(.failure(error))
        }
      }
    }
  }
  
  func uploadMediaToStorage(
    result: PHPickerResult,
    foldername: String?,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    var mediaName = ""
    loadTasksQueue.async { [weak self] in
      guard let self = self else { return }
      let group = DispatchGroup()
      var added = false
      group.enter()
      result.itemProvider.loadFileRepresentation(
        forTypeIdentifier: UTType.image.identifier) { url, error in
          if let error = error {
            print(error)
            group.leave()
            return
          }
          guard let url = url else { return }
          mediaName = url.lastPathComponent
          self.uploadDataToStorage(
            url,
            folderName: foldername
          ) { result in
            switch result {
            case .success:
              print("Success load for \(mediaName)")
              added = true
              completion(.success(mediaName))
              group.leave()
            case .failure(let error):
              print(error)
            }
          }
        }
      group.wait()
      if added {
        return
      }
      result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
        if let error = error {
          completion(.failure(error))
          print(error)
        }
        guard let url = url else { return }
        mediaName = url.lastPathComponent
        self.uploadDataToStorage(
          url,
          folderName: foldername
        ) { result in
          switch result {
          case .success:
            completion(.success(mediaName))
          case .failure(let error):
            completion(.failure(error))
            print(error)
            return
          }
        }
      }
    }
  }
  
}

// MARK: - Helpers
extension FirebaseStorageService {
  
  private func getContentType(_ filename: String) -> String {
    return "image/jpeg"
  }
  
  func getReference(
    fileName: String?,
    folderName: String?
  ) -> StorageReference {
    if let folder = folderName {
      if let fileName = fileName {
        return storageRef
          .child(Constants.usersPath)
          .child(currentUserID)
          .child(folder)
          .child(fileName)
      } else {
        return storageRef
          .child(Constants.usersPath)
          .child(currentUserID)
          .child(folder)
      }
    } else {
      guard let fileName = fileName else {
        return storageRef.child(Constants.usersPath).child(currentUserID)
      }
      return storageRef
        .child(Constants.usersPath)
        .child(currentUserID)
        .child(fileName)
    }
  }
  
}
