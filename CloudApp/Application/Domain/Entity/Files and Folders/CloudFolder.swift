//
//  CloudFolder.swift
//  CloudApp
//
//  Created by Timofey on 16/8/22.
//

import Foundation

class CloudFolder {
  var name: String
  var folders: [String: Folder] = [:]
  var items: [String: CloudItem] = [:]
  
  init(name: String) {
    self.name = name
    self.folders = [:]
    self.items = [:]
  }
}
