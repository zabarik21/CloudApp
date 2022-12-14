//
//  AlertService.swift
//  TinderApp
//
//  Created by Timofey on 29/7/22.
//

import Foundation
import RxSwift
import RxRelay

class AlertService {
  
  typealias AlertDescription = (title: String, message: String)
  
  static let shared = AlertService()
  
  private let bag = DisposeBag()
  
  public var alertPublisher = PublishRelay<AlertDescription>()
  public var errorAlertPublisher = PublishRelay<String>()
  
  public var alertObservable: Observable<AlertDescription> {
    return alertPublisher.share()
  }
  
  public var errorAlertObservable: Observable<String> {
    return errorAlertPublisher.share()
  }
  
  private init() {}

}
