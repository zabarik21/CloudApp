//
//  CoordinatorProtocol.swift
//  CloudApp
//
//  Created by Timofey on 22/8/22.
//

import Foundation
import UIKit


protocol Coordinator: AnyObject {
  
  var children: [Coordinator] { get set }
  var nav: UINavigationController { get set }
  
  func start()
  
}


