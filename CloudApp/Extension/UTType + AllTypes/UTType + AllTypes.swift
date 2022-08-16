//
//  UTType + AllTypes.swift
//  CloudApp
//
//  Created by Timofey on 16/8/22.
//

import Foundation
import UniformTypeIdentifiers


extension UTType {
  
  static func allUTITypes() -> [UTType] {
    let types : [UTType] =
    [.item,
     .content,
     .compositeContent,
     .diskImage,
     .data,
     .directory,
     .resolvable,
     .symbolicLink,
     .executable,
     .mountPoint,
     .aliasFile,
     .urlBookmarkData,
     .url,
     .fileURL,
     .rtf,
     .html,
     .xml,
     .yaml,
     .sourceCode,
     .assemblyLanguageSource,
     .cSource,
     .objectiveCSource,
     .swiftSource,
     .cPlusPlusSource,
     .objectiveCPlusPlusSource,
     .cHeader,
     .cPlusPlusHeader]
    
    let types_1: [UTType] =
    [.script,
     .appleScript,
     .osaScript,
     .osaScriptBundle,
     .javaScript,
     .shellScript,
     .perlScript,
     .pythonScript,
     .rubyScript,
     .phpScript,
     .json,
     .propertyList,
     .xmlPropertyList,
     .binaryPropertyList,
     .pdf,
     .rtfd,
     .flatRTFD,
     .webArchive,
     .image,
     .jpeg,
     .tiff,
     .gif,
     .png,
     .icns,
     .bmp,
     .ico,
     .rawImage,
     .svg,
     .heif,
     .heic,
     .webP,
     .threeDContent,
     .usd,
     .usdz,
     .realityFile,
     .sceneKitScene,
     .arReferenceObject,
     .audiovisualContent]
    
    let types_2: [UTType] =
    [.movie,
     .video,
     .audio,
     .mpeg,
     .mpeg2Video,
     .mpeg2TransportStream,
     .mp3,
     .mpeg4Movie,
     .mpeg4Audio,
     .appleProtectedMPEG4Audio,
     .appleProtectedMPEG4Video,
     .avi,
     .aiff,
     .wav,
     .midi,
     .epub,
     .log]
      .compactMap({ $0 })
    
    return types + types_1 + types_2
  }
  
}
