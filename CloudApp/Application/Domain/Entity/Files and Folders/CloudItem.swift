//
//  CloudItem.swift
//  CloudApp
//
//  Created by Timofey on 16/8/22.
//

import Foundation

struct CloudItem {
  var name: String
  var path: String
}


extension CloudItem: Equatable {
  static func ==(_ lhs: CloudItem, rhs: CloudItem) -> Bool {
    return lhs.path == rhs.path
  }
}
