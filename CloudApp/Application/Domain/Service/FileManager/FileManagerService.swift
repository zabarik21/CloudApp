//
//  FileManagerService.swift
//  StorageTest
//
//  Created by Timofey on 11/8/22.
//

import Foundation
import FileProvider


class FileManagerService {

  static let shared = FileManagerService()
  
  private let manager = FileManager.default
  
  private let tasksQueue = DispatchQueue(
    label: "fileManagerQueue",
    qos: .utility,
    attributes: .concurrent
  )
  
  private var rootDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  
  private init() {}
  
  func getData(
    from url: URL,
    completion: @escaping (Result<Data, Error>) -> Void
  ) {
    tasksQueue.sync {
      var isDir: ObjCBool = false
      if self.manager.fileExists(atPath: url.path, isDirectory: &isDir) {
        guard let data = self.manager.contents(atPath: url.path) else {
          completion(.failure(DataError.nilData))
          return
        }
        guard data.count < 20971520 else {
          completion(.failure(DataError.bigSize))
          return
        }
        completion(.success(data))
      } else {
        completion(.failure(DataError.fileDoesntExists))
      }
    }
  }
  
  func saveToFiles(
    data: Data,
    filename: String,
    foldername: String?,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    tasksQueue.sync {
      let fileDirectory = self.getDirectory(filename: filename, foldername: foldername)
      let folderDirectory = self.getDirectory(filename: nil, foldername: foldername)
      guard !self.checkExisting(saveDirectory: fileDirectory, isDirectory: false) else {
        completion(.failure(DataError.alreadyExists))
        return
      }
      
      if foldername != nil {
        if !checkExisting(saveDirectory: folderDirectory, isDirectory: true) {
          do {
            try manager.createDirectory(at: folderDirectory, withIntermediateDirectories: true)
          } catch(let error) {
            completion(.failure(error))
          }
        }
      }
      
      do {
        try data.write(to: fileDirectory, options: self.getWriteOptions())
        completion(.success(()))
      } catch(let error) {
        completion(.failure(error))
      }
    }
  }
  
}

// MARK: - Helpers
extension FileManagerService {
  
  private func tryCreateRootFolder() {
    var isDir: ObjCBool = true
    if !FileManager.default.fileExists(atPath: rootDirectory.path, isDirectory: &isDir) {
      do {
        try manager.createDirectory(
          atPath: self.rootDirectory.path,
          withIntermediateDirectories: true,
          attributes: nil
        )
      } catch(let error) {
        print(error)
      }
    }
  }
  
  func checkExisting(saveDirectory: URL, isDirectory: Bool) -> Bool {
    var isDir: ObjCBool = ObjCBool(booleanLiteral: isDirectory)
    return manager.fileExists(atPath: saveDirectory.path, isDirectory: &isDir)
  }
  
  private func getWriteOptions() -> NSData.WritingOptions {
    return NSData.WritingOptions.atomic
  }
  
  private func getDirectory(filename: String?, foldername: String?) -> URL {
    if let folder = foldername {
      if let file = filename {
        return rootDirectory
          .appendingPathComponent(folder, isDirectory: true)
          .appendingPathComponent(file, isDirectory: false)
      } else {
        return rootDirectory
          .appendingPathComponent(folder, isDirectory: true)
      }
    } else {
      if let name = filename {
        return rootDirectory
          .appendingPathComponent(name, isDirectory: false)
      } else {
        return rootDirectory
      }
    }
  }
  
}
