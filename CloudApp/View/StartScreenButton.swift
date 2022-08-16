//
//  StartScreenButton.swift
//  CloudApp
//
//  Created by Timofey on 16/8/22.
//

import Foundation
import UIKit

enum ButtonStyle {
  case dark
  case light
}

class StartScreenButton: UIButton {
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = self.bounds.height / 2
  }
  
  init(with style: ButtonStyle, title: String) {
    super.init(frame: .zero)
    setupButton(with: style)
    setTitle(title, for: .normal)
  }
  
  private func setupButton(with style: ButtonStyle) {
    let titleColor: UIColor = ((style == .dark) ? .white : .black)
    let buttonBackgroundColor: UIColor = ((style == .light) ? .white : .black.withAlphaComponent(0.5))
    setTitleColor(titleColor, for: .normal)
    setTitleColor(titleColor.withAlphaComponent(0.5), for: .highlighted)
    
    backgroundColor = buttonBackgroundColor
    titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
  }

  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
