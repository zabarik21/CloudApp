//
//  FilesServiceProtocol.swift
//  CloudApp
//
//  Created by Timofey on 24/8/22.
//

import Foundation
import PhotosUI

protocol FilesServiceProtocol {
  func fetchFilesFrom(
    foldername: String?,
    completion: @escaping (Result<[CloudItem], Error>) -> Void
  )
  
  func renameFile(
    _ newName: String,
    oldFilename: String,
    foldername: String?,
    completion: @escaping (Result<Void, Error>) -> Void
  )
  func deleteFile(
    filename: String,
    foldername: String?,
    completion: @escaping (Result<Void, Error>) -> Void
  )
  func uploadDataToStorage(
    _ url: URL?,
    folderName: String?,
    completion: @escaping (Result<String, Error>) -> Void
  )
  func uploadMediaToStorage(
    result: PHPickerResult,
    foldername: String?,
    completion: @escaping (Result<String, Error>) -> Void
  )
  
  func loadDataFromStorage(
    filename: String,
    folderName: String?,
    completion: @escaping (Result<Void, Error>) -> Void
  )
}
