//
//  LayoutSwitcherView.swift
//  CloudApp
//
//  Created by Timofey on 15/8/22.
//

import Foundation
import UIKit
import RxRelay
import SnapKit

protocol LayoutSwitcherViewDelegate: AnyObject {
  func sliderSwitched(to type: LayoutType)
}


class LayoutSwitcherView: UIView {
  
  var switchRelay = PublishRelay<LayoutType>()
  
  private var laytoutSwitch: UISwitch!
  private var gridLayoutImage: UIImageView!
  private var listLayoutImage: UIImageView!
  
  private var type: LayoutType
  
  init(type: LayoutType) {
    self.type = type
    super.init(frame: .zero)
    setupUI()
  }
  
  @objc func switchChanged() {
    if laytoutSwitch.isOn {
      switchRelay.accept(.list)
    } else {
      switchRelay.accept(.grid)
    }
  }
  
  func switchTo(layoutType: LayoutType) {
    self.type = layoutType
    self.laytoutSwitch.isOn = layoutType == .list
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Setup UI
extension LayoutSwitcherView {
  
  private func setupUI() {
    setupSlider()
    setupImages()
    setupConstraitns()
  }
  
  private func setupSlider() {
    laytoutSwitch = UISwitch()
    laytoutSwitch.isOn = type == .list
    laytoutSwitch.tintColor = .white
    laytoutSwitch.onTintColor = .white
    laytoutSwitch.thumbTintColor = .mainBg
    laytoutSwitch.layer.backgroundColor = UIColor.white.cgColor
    laytoutSwitch.layer.cornerRadius = 15
    laytoutSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
  }
 
  private func setupImages() {
    gridLayoutImage = UIImageView()
    listLayoutImage = UIImageView()
    let config = UIImage.SymbolConfiguration(pointSize: 18)
    let gridImage = UIImage(systemName: "square.grid.2x2", withConfiguration: config)
    let listImage = UIImage(systemName: "list.dash", withConfiguration: config)
    gridLayoutImage.contentMode = .center
    gridLayoutImage.image = gridImage
    listLayoutImage.contentMode = .center
    listLayoutImage.image = listImage
    listLayoutImage.tintColor = .white
    gridLayoutImage.tintColor = .white
  }
  
  private func setupConstraitns() {
    
    addSubview(laytoutSwitch)
    
    laytoutSwitch.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.centerX.equalToSuperview()
    }
    
    addSubview(gridLayoutImage)
    
    gridLayoutImage.snp.makeConstraints { make in
      make.trailing
        .equalTo(laytoutSwitch.snp.leading)
        .offset(-6)
      make.centerY.equalToSuperview()
    }
    
    addSubview(listLayoutImage)
    
    listLayoutImage.snp.makeConstraints { make in
      make.leading
        .equalTo(laytoutSwitch.snp.trailing)
        .offset(6)
      make.centerY.equalToSuperview()
    }
  }
}

