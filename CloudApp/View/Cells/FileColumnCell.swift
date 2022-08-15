//
//  FileColumnCell.swift
//  CollectionViewTest
//
//  Created by Timofey on 13/8/22.
//

import Foundation
import UIKit

protocol ReuseIdProtocol {
  static var reuseId: String { get }
}

class FileColumnCell: UICollectionViewCell, ReuseIdProtocol {
  
  static var reuseId: String {
    return String(describing: self)
  }
 
  private enum Constants {
    static let cellCornerRadius: CGFloat = 20
    static let imageCornerRadius: CGFloat = 10
    static let imageViewSideMult: CGFloat = 0.647
    static let fileImageName = "doc.fill"
    static let horizontalMargin: CGFloat = 30
    static let topMargin: CGFloat = 17
  }
  
  private var fileTitleLabel: UILabel!
  private var folderImageView: UIImageView!
  
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
      self.fileTitleLabel.text = viewModel?.filename
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
  }
  
  private func setupImageView() {
    folderImageView = UIImageView()
    let config = UIImage.SymbolConfiguration(pointSize: 58, weight: .light, scale: .small)
    folderImageView.contentMode = .center
    folderImageView.image = UIImage(systemName: Constants.fileImageName, withConfiguration: config)
    folderImageView.tintColor = .fileIconColor
    folderImageView.layer.cornerRadius = Constants.imageCornerRadius
    folderImageView.layer.backgroundColor = UIColor.mainBg.cgColor
  }
  
  private func setupConstraitns() {
    
    let width = self.bounds.width
    
    addSubview(folderImageView)
    
    folderImageView.snp.makeConstraints { make in
      make.centerY.centerX.equalToSuperview()
      make.width.height.equalTo(Constants.imageViewSideMult * width)
    }
    
    addSubview(fileTitleLabel)
    
    fileTitleLabel.snp.makeConstraints { make in
      make.horizontalEdges
        .equalToSuperview()
        .inset(Constants.horizontalMargin)
      make.top
        .equalTo(folderImageView.snp.bottom)
        .offset(10)
    }
    
  }
}
