//
//  FileManagerService.swift
//  StorageTest
//
//  Created by Timofey on 11/8/22.
//

import Foundation

enum DataError: Error {
  case nilData
  case fileDoesntExists
  case bigSize
  case alreadyExists
  case invalidDataURL
}

extension FileManagerService {
  private enum Constants {
    static let rootDirTitle = "Root Directory"
  }
}

class FileManagerService {
  
  static let shared = FileManagerService()
  
  private let manager = FileManager.default
  
  private let tasksQueue = DispatchQueue(
    label: "fileManagerQueue",
    qos: .utility,
    attributes: .concurrent
  )
  
  private var rootDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(Constants.rootDirTitle, isDirectory: true)
  
  private init() {
    tryCreateRootFolder()
  }
  
  func getData(
    from url: URL,
    completion: @escaping (Result<Data, Error>) -> Void
  ) {
    tasksQueue.async {
      var isDir: ObjCBool = false
      print(url.path)
      // try removing that check and get file from not app directory
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
    tasksQueue.async {
      let fileDirectory = self.getDirectory(filename: filename, foldername: foldername)
      guard !self.checkExisting(name: filename, saveDirectory: fileDirectory, isDirectory: false) else {
        completion(.failure(DataError.alreadyExists))
        return
      }
      do {
        try data.write(to: fileDirectory, options: self.getWriteOptions())
        completion(.success(()))
      } catch(let error) {
        completion(.failure(error))
        print(error)
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
  
  func checkExisting(name: String, saveDirectory: URL, isDirectory: Bool) -> Bool {
    var isDir: ObjCBool = ObjCBool(booleanLiteral: isDirectory)
    return manager.fileExists(atPath: saveDirectory.path, isDirectory: &isDir)
  }
  
  private func getWriteOptions() -> NSData.WritingOptions {
    return NSData.WritingOptions.atomic
  }
  
  private func getDirectory(filename: String, foldername: String?) -> URL {
    if let folder = foldername {
      return rootDirectory.appendingPathComponent(folder, isDirectory: true).appendingPathComponent(filename, isDirectory: false)
    } else {
      return rootDirectory.appendingPathComponent(filename, isDirectory: false)
    }
  }
  
}
