//
//  UILabel + Init.swift
//  CollectionViewTest
//
//  Created by Timofey on 13/8/22.
//

import Foundation
import UIKit


extension UILabel {
  convenience init(text: String, fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor) {
    self.init()
    self.text = text
    self.font = .systemFont(ofSize: fontSize, weight: weight)
    self.textColor = textColor
  }
}
