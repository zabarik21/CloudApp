//
//  UpdateRootVCService.swift
//  CloudApp
//
//  Created by Timofey on 16/8/22.
//

import Foundation
import RxSwift

class UpdateRootVCService {
  
  static let changeViewControllerPublisher = PublishSubject<Void>()
  
  static var chagneViewControllerObservable: Observable<Void> {
    return changeViewControllerPublisher.asObservable()
  }
  
}
