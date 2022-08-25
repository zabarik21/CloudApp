//
//  FileCellProtocol.swift
//  CloudApp
//
//  Created by Timofey on 17/8/22.
//

import Foundation
import UIKit
import UniformTypeIdentifiers


enum FileCellImageConstants {
  static let bookImageName = "book.fill"
  static let videoImageName = "video.fill"
  static let audioImageName = "music.note"
  static let fileImageName = "doc.fill"
  static let photoImageName = "photo"
}


protocol FileCellProtocol {
  var fileImageView: UIImageView! { get }
  func switchFileImage(_ ext: String, _ imagePointSize: CGFloat)
}


extension FileCellProtocol {
  func switchFileImage(_ ext: String, _ imagePointSize: CGFloat) {
    DispatchQueue.main.async {
      guard let type = UTType(filenameExtension: ext) else { return }
      var imageName = FileCellImageConstants.fileImageName
      if type == .epub {
        imageName = FileCellImageConstants.bookImageName
      } else if type.isSubtype(of: .image) {
        imageName = FileCellImageConstants.photoImageName
      } else if type.isSubtype(of: .video) || type.isSubtype(of: .movie) {
        imageName = FileCellImageConstants.videoImageName
      } else if type.isSubtype(of: .audio) {
        imageName = FileCellImageConstants.audioImageName
      }
      let config = UIImage.SymbolConfiguration(pointSize: imagePointSize, weight: .light, scale: .small)
      self.fileImageView.image = UIImage(systemName: imageName, withConfiguration: config)
    }
  }
}
