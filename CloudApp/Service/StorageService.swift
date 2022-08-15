//
//  StorageService.swift
//  CollectionViewTest
//
//  Created by Timofey on 13/8/22.
//

import Foundation


class StorageService {
  
  var files = [FileCellViewModel]()
  var folders = [FolderCellViewModel]()
  
  weak var filesDelegate: StorageServiceFilesDelegate?
  weak var foldersDelegate: StorageServiceFoldersDelegate?
  
  func fetchFiles(foldername: String) {
    filesDelegate?.filesRecieved([
      FileCellViewModel(filename: "New file.png", ext: "png"),
      FileCellViewModel(filename: "New file1.png", ext: "png"),
      FileCellViewModel(filename: "New file2.png", ext: "png"),
      FileCellViewModel(filename: "New file3.png", ext: "png"),
      FileCellViewModel(filename: "New file4.png", ext: "png"),
      FileCellViewModel(filename: "New file5.png", ext: "png"),
      FileCellViewModel(filename: "New file6.png", ext: "png"),
      FileCellViewModel(filename: "New file7.png", ext: "png"),
      FileCellViewModel(filename: "New file8.png", ext: "png"),
    ])
  }
  
  func fetchFolders() {
    foldersDelegate?.foldersRecieved([
      FolderCellViewModel(name: "New folder1", objectsCount: Int.random(in: 0...6)),
      FolderCellViewModel(name: "New folder2", objectsCount: Int.random(in: 0...6)),
      FolderCellViewModel(name: "New folder3", objectsCount: Int.random(in: 0...6)),
      FolderCellViewModel(name: "New folder4", objectsCount: Int.random(in: 0...6)),
      FolderCellViewModel(name: "New folder5", objectsCount: Int.random(in: 0...6)),
      FolderCellViewModel(name: "New folder6", objectsCount: Int.random(in: 0...6)),
      FolderCellViewModel(name: "New folder7", objectsCount: Int.random(in: 0...6)),
      FolderCellViewModel(name: "New folder8", objectsCount: Int.random(in: 0...6)),
      FolderCellViewModel(name: "New folder9", objectsCount: Int.random(in: 0...6)),
      FolderCellViewModel(name: "New folder10", objectsCount: Int.random(in: 0...6)),
      FolderCellViewModel(name: "New folder11", objectsCount: Int.random(in: 0...6)),
      FolderCellViewModel(name: "New folder12", objectsCount: Int.random(in: 0...6)),
      FolderCellViewModel(name: "New folder13", objectsCount: Int.random(in: 0...6)),
      FolderCellViewModel(name: "New folder14", objectsCount: Int.random(in: 0...6))
    ])
  }
  
  func loadFile(filename: String, folderName: String) {
    print("loading file \(filename)")
  }
  
}
protocol StorageServiceFoldersDelegate: AnyObject {
  func foldersRecieved(_ folders: [FolderCellViewModel])
}

protocol StorageServiceFilesDelegate: AnyObject {
  func filesRecieved(_ files: [FileCellViewModel])
}
