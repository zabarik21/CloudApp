//
//  FileColumnCell.swift
//  CollectionViewTest
//
//  Created by Timofey on 13/8/22.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

protocol ReuseIdProtocol {
  static var reuseId: String { get }
}



class FileColumnCell: UICollectionViewCell, ReuseIdProtocol, FileCellProtocol {
  
  static var reuseId: String {
    return String(describing: self)
  }
 
  private enum Constants {
    static let cellCornerRadius: CGFloat = 20
    static let imageCornerRadius: CGFloat = 10
    static let imageViewSideMult: CGFloat = 0.647
    static let horizontalMargin: CGFloat = 30
    static let topMargin: CGFloat = 17
    static let imagePointSize: CGFloat = 58
  }
  
  private var fileTitleLabel: UILabel!
  var fileImageView: UIImageView!
  
  var viewModel: FileCellViewModel? {
    didSet {
      self.updateUI(with: viewModel)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupElements()
  }
  
  func updateUI(with viewModel: FileCellViewModel?) {
    DispatchQueue.main.async {
      guard let viewModel = viewModel else {
        return
      }
      self.fileTitleLabel.text = viewModel.filename
      self.switchFileImage(viewModel.ext, Constants.imagePointSize)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: SetupUI
extension FileColumnCell {
  
  private func setupElements() {
    setupLayer()
    setupLabels()
    setupImageView()
    setupConstraitns()
  }
  
  private func setupLayer() {
    layer.cornerRadius = Constants.cellCornerRadius
    layer.backgroundColor = UIColor.cellBackgroundColor.cgColor
  }
  
  private func setupLabels() {
    fileTitleLabel = UILabel(
      text: "File title",
      fontSize: 16,
      weight: .bold,
      textColor: .white
    )
    fileTitleLabel.lineBreakMode = .byTruncatingMiddle
    fileTitleLabel.textAlignment = .center
  }
  
  private func setupImageView() {
    fileImageView = UIImageView()
    let config = UIImage.SymbolConfiguration(pointSize: Constants.imagePointSize, weight: .light, scale: .small)
    fileImageView.contentMode = .center
    fileImageView.image = UIImage(systemName: FileCellImageConstants.fileImageName, withConfiguration: config)
    fileImageView.tintColor = .fileIconColor
    fileImageView.layer.cornerRadius = Constants.imageCornerRadius
    fileImageView.layer.backgroundColor = UIColor.mainBg.cgColor
  }
  
  private func setupConstraitns() {
    
    let width = self.bounds.width
    
    addSubview(fileImageView)
    
    fileImageView.snp.makeConstraints { make in
      make.centerY.centerX.equalToSuperview()
      make.width.height.equalTo(Constants.imageViewSideMult * width)
    }
    
    addSubview(fileTitleLabel)
    
    fileTitleLabel.snp.makeConstraints { make in
      make.horizontalEdges
        .equalToSuperview()
        .inset(Constants.horizontalMargin)
      make.top
        .equalTo(fileImageView.snp.bottom)
        .offset(10)
    }
    
  }
}
