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


enum SnapshotAction {
  case added
  case removed
  case modified(name: String)
}

enum FirebaseStorageError: Error {
  case alreadyExists
  case nilData
  case stringEncoding
  case nonEnoughRights
}

extension FirebaseStorageError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .alreadyExists:
      return NSLocalizedString("File already exists", comment: "Firebase error")
    case .nilData:
      return NSLocalizedString("Data for that path is empty", comment: "Firebase error")
    case .stringEncoding:
      return NSLocalizedString("Cant decode filename", comment: "Firebase error")
    case .nonEnoughRights:
      return NSLocalizedString("Not enuogh rights to load this file", comment: "Firebase error")
    }
  }
}

class FirebaseStorageService {
  
  private enum Constants {
    static let usersPath = "users"
    static let rootFolderTitle = "Root"
    static let hiddenFileName = "12c8f301-50ea-4a38-b2ca-1f4b424da6cd.txt"
  }
  
  static let shared = FirebaseStorageService()
  
  private let filesService = FileManagerService.shared
  private let authService = AuthenticationService.shared
  
  private let loadTasksQueue = DispatchQueue(
    label: "tasksQueue",
    qos: .utility,
    attributes: .concurrent
  )
  
  private let fetchFilesQuque = DispatchQueue.global(qos: .userInitiated)
  private let fetchFolderQueue = DispatchQueue.global(qos: .userInitiated)
  
  private let storage: CloudFolder? = nil
  
  private var snapshotSubject = PublishSubject<CloudFolder>()
  public var snapshotListener: Observable<CloudFolder> {
    return snapshotSubject.asObservable()
  }
  
  private var snapShot = CloudFolder(name: Constants.rootFolderTitle) {
    didSet {
      snapshotSubject.onNext(snapShot)
    }
  }
  
  private init() {}
  
  private var currentUserID: String {
    return AuthenticationService.shared.getCurrentUserId() ?? "default"
  }
  
  private let storageRef = Storage.storage().reference()
  
  func deleteFile(
    filename: String,
    foldername: String?,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard filename != Constants.hiddenFileName else {
      completion(.failure(FirebaseStorageError.nonEnoughRights))
      return
    }
    let ref = getReference(fileName: filename, folderName: foldername)
    ref.delete { error in
      if let error = error {
        completion(.failure(error))
      } else {
        self.updateSnapshot(action: .removed, folderName: foldername, fileName: filename)
        completion(.success(()))
      }
    }
  }
  
  func fetchFoldersWithFiles(completion: @escaping (Result<[Folder], Error>) -> Void) {
    let group = DispatchGroup()
    var refs = [StorageReference]()
    let rootRef = getReference(fileName: nil, folderName: nil)
    fetchFilesQuque.async {
      group.enter()
      rootRef.listAll { result in
        defer { group.leave() }
        switch result {
        case .success(let storageListResult):
          refs = storageListResult.prefixes
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
    let successGroupt = DispatchGroup()
    var folders = [Folder]()
    successGroupt.enter()
    DispatchQueue.global().async {
      group.wait()
      for pref in refs {
        successGroupt.enter()
        self.fetchFilesFrom(pref) { result in
          defer { successGroupt.leave() }
          switch result {
          case .success(let items):
            var itemsDict = [String: CloudItem]()
            for item in items {
              if item.name == Constants.hiddenFileName { continue }
              itemsDict[item.name] = item
            }
            folders.append(Folder(name: pref.name, items: itemsDict))
          case .failure(let error):
            completion(.failure(error))
            print(error)
          }
        }
      }
    }
    DispatchQueue.global().async {
      successGroupt.wait()
      completion(.success(folders))
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
    self.loadTasksQueue.async {
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
                self.updateSnapshot(action: .modified(name: newName), folderName: foldername, fileName: oldFilename)
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
  ) -> StorageDownloadTask? {
    let ref = getReference(fileName: filename, folderName: folderName)
    let task = ref.getData(maxSize: 20000000) { data, error in
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
    return task
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
    fetchFilesQuque.async {
      self.fetchFilesFrom(ref) { result in
        switch result {
        case .success(let items):
          let hidedFileItems = items.filter { $0.name != Constants.hiddenFileName }
          completion(.success(hidedFileItems))
          for item in items {
            self.updateSnapshot(action: .added, folderName: foldername, fileName: item.name)
          }
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
            items.append(
              CloudItem(
                name: item.name,
                path: item.fullPath
              )
            )
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
  ) -> StorageUploadTask? {
    guard let url = url else {
      completion(.failure(DataError.invalidDataURL))
      return nil
    }
    
    let name = url.lastPathComponent
    
    let ref = getReference(fileName: name, folderName: folderName)
    let metadata = StorageMetadata()
    var uploadTask: StorageUploadTask?
    
    DispatchQueue.global(qos: .utility).sync {
      filesService.getData(from: url) { result in
        switch result {
        case .success(let data):
          uploadTask = ref.putData(data, metadata: metadata) { result in
            switch result {
            case .success(let metadata):
              print(metadata)
              self.updateSnapshot(action: .added, folderName: folderName, fileName: name)
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
    return uploadTask
  }
  
  func createFolder(
    foldername: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    let ref = getReference(fileName: Constants.hiddenFileName, folderName: foldername)
    
    ref.putData(.hiddenFileData, metadata: nil) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  func uploadDataToStorage(
    _ data: Data?,
    folderName: String?,
    fileName: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) -> StorageUploadTask? {
    guard let data = data else {
      completion(.failure(DataError.nilData))
      return nil
    }
    
    let ref = getReference(fileName: fileName, folderName: folderName)
    let metadata = StorageMetadata()
    
    let uploadTask = ref.putData(data, metadata: metadata) { result in
      switch result {
      case .success(let metadata):
        print(metadata)
        self.updateSnapshot(action: .added, folderName: folderName, fileName: fileName)
        completion(.success(()))
      case .failure(let error):
        print(error)
        completion(.failure(error))
      }
    }
    return uploadTask
  }
  
  func updateSnapshot(
    action: SnapshotAction,
    folderName: String?,
    fileName: String
  ) {
    switch action {
    case .added:
      appendToSnapshot(folderName: folderName, fileName: fileName)
    case .removed:
      removeFromSnapshot(folderName: folderName, fileName: fileName)
    case .modified(let newName):
      renameInSnapshot(newName, folderName: folderName, fileName: fileName)
    }
  }
  
  private func renameInSnapshot(
    _ newname: String,
    folderName: String?,
    fileName: String
  ) {
    if let folder = folderName {
      guard let oldItem = snapShot.folders[folder]?.items[fileName] else { return }
      removeFromSnapshot(folderName: folderName, fileName: fileName)
      snapShot.folders[folder]?.items[fileName] = CloudItem(
        name: newname,
        path: oldItem.path
      )
    } else {
      guard let oldItem = snapShot.items[fileName] else { return }
      removeFromSnapshot(folderName: folderName, fileName: fileName)
      snapShot.items[fileName] = CloudItem(
        name: newname,
        path: oldItem.path
      )
    }
  }
  
  private func removeFromSnapshot(
    folderName: String?,
    fileName: String
  ) {
    if let folder = folderName {
      self.snapShot.folders[folder]?.items.removeValue(forKey: fileName)
    } else {
      self.snapShot.items.removeValue(forKey: fileName)
    }
  }
  
  private func appendToSnapshot(
    folderName: String?,
    fileName: String
  ) {
    let path = getReference(fileName: fileName, folderName: folderName).fullPath
    let newItem =  CloudItem(name: fileName, path: path)
    if let folder = folderName {
      snapShot.folders[folder, default: Folder(name: folder, items: [:])].items[fileName] = newItem
    } else {
      self.snapShot.items[fileName] = newItem
    }
  }
  
  func uploadMediaToStorage(
    result: PHPickerResult,
    foldername: String?,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    var mediaName = ""
    loadTasksQueue.async {
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
          _ = self.uploadDataToStorage(
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
        _ = self.uploadDataToStorage(
          url,
          folderName: foldername
        ) { result in
          switch result {
          case .success:
            print("Success load for \(mediaName)")
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

