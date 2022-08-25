//
//  UIStackView + Init.swift
//  CollectionViewTest
//
//  Created by Timofey on 15/8/22.
//

import Foundation
import UIKit


extension UIStackView {
  
  convenience init(
    arrangedSubviews: [UIView],
    spacing: CGFloat,
    axis: NSLayoutConstraint.Axis = .horizontal,
    distribution: UIStackView.Distribution = .equalSpacing,
    alignment: UIStackView.Alignment = .center
  ) {
    self.init(arrangedSubviews: arrangedSubviews)
    self.axis = axis
    self.spacing = spacing
    self.distribution = distribution
    self.alignment = alignment
  }
  
}
