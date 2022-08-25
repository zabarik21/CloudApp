//
//  FirebaseStorageError.swift
//  CloudApp
//
//  Created by Timofey on 17/8/22.
//

import Foundation

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
