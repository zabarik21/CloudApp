//
//  FolderServiceProtocol.swift
//  CloudApp
//
//  Created by Timofey on 24/8/22.
//

import Foundation

protocol FolderServiceProtocol {
  func fetchFolders(
    completion: @escaping (Result<[FolderCellViewModel], Error>) -> Void
  )
  
  func createFolder(
    foldername: String,
    completion: @escaping (Result<Void, Error>) -> Void
  )
  
}
