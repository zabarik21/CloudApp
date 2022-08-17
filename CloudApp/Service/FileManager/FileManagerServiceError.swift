//
//  FileManagerServiceError.swift
//  CloudApp
//
//  Created by Timofey on 17/8/22.
//

import Foundation

enum DataError: Error {
  case nilData
  case fileDoesntExists
  case bigSize
  case alreadyExists
  case invalidDataURL
}

extension DataError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .nilData:
      return NSLocalizedString("Data is empty", comment: "Data Errror")
    case .fileDoesntExists:
      return NSLocalizedString("File doesnt exists", comment: "Data Errror")
    case .bigSize:
      return NSLocalizedString("Maximal allowed size is 20 mb", comment: "Data Errror")
    case .alreadyExists:
      return NSLocalizedString("File already exists", comment: "Data Errror")
    case .invalidDataURL:
      return NSLocalizedString("Invalud URL", comment: "Data Errror")
    }
  }
}
