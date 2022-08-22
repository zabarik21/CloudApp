//
//  FileCellViewModel.swift
//  CloudApp
//
//  Created by Timofey on 15/8/22.
//

import Foundation

struct FileCellViewModel: Equatable, Hashable {
  var filename: String
  var ext: String { 
    return getFileExtension(filename: filename)
  }
  
  private func getFileExtension(filename: String) -> String {
    var ext = ""
    for char in filename.reversed() {
      if char == "." { return ext }
      ext.insert(char, at: ext.startIndex)
    }
    return ext
  }
}
