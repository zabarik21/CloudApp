//
//  Folder.swift
//  CloudApp
//
//  Created by Timofey on 16/8/22.
//

import Foundation


struct Folder {
  var name: String
  var items: [String: CloudItem] {
    didSet {
      self.objectsCount = items.count
    }
  }
  var objectsCount: Int?
  
  init(name: String, items: [String: CloudItem]) {
    self.name = name
    self.items = items
    self.objectsCount = items.count
  }
}
