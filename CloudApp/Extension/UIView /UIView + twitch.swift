//
//  UIView + twitch.swift
//  CloudApp
//
//  Created by Timofey on 16/8/22.
//

import UIKit

extension UIView {
  
  func twitch() {
    let basicAnimation = CAKeyframeAnimation(keyPath: "position.x")
    basicAnimation.values = [0, 10, -10, 10, 0]
    basicAnimation.keyTimes = [0, 0.16, 0.5, 0.83, 1]
    basicAnimation.duration = 0.3
    basicAnimation.isAdditive = true
    layer.add(basicAnimation, forKey: "twitch")
  }
  
}
