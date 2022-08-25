//
//  FolderColumnCell.swift
//  CollectionViewTest
//
//  Created by Timofey on 13/8/22.
//

import Foundation
import UIKit


class FolderColumnCell: UICollectionViewCell, ReuseIdProtocol {  
  
  static let reuseId: String = "FolderColumnCell"
  
  private enum Constants {
    static let cellCornerRadius: CGFloat = 20
    static let imageCornerRadius: CGFloat = 10
    static let imageViewSideMult: CGFloat = 0.318
    static let folderImageName = "folder.fill"
    static let horizontalMargin: CGFloat = 17
  }
  
  private var objectsCountLabel: UILabel!
  private var folderTitleLabel: UILabel!
  private var folderImageView: UIImageView!
  
  var viewModel: FolderCellViewModel? {
    didSet {
      self.updateUI(with: viewModel)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupElements()
  }
  
  func updateUI(with viewModel: FolderCellViewModel?) {
    DispatchQueue.main.async {
      self.objectsCountLabel.text = "Uknown objects count"
      self.folderTitleLabel.text = viewModel?.name
    }
  }
  
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: SetupUI
extension FolderColumnCell {
  
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
    objectsCountLabel = UILabel(
      text: "Folder",
      fontSize: 12,
      weight: .bold,
      textColor: .darkTextColor
    )
    folderTitleLabel = UILabel(
      text: "Objects count",
      fontSize: 16,
      weight: .bold,
      textColor: .white
    )
  }
  
  private func setupImageView() {
    folderImageView = UIImageView()
    folderImageView.contentMode = .center
    let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .light, scale: .small)
    folderImageView.image = UIImage(systemName: Constants.folderImageName, withConfiguration: config)
    folderImageView.tintColor = .fileIconColor
    folderImageView.layer.cornerRadius = Constants.imageCornerRadius
    folderImageView.layer.backgroundColor = UIColor.mainBg.cgColor
  }
  
  private func setupConstraitns() {
    
    let width = self.bounds.width
    
    addSubview(folderImageView)
    
    folderImageView.snp.makeConstraints { make in
      make.leading
        .equalToSuperview()
        .offset(Constants.horizontalMargin)
      make.width.height.equalTo(Constants.imageViewSideMult * width)
      make.top
        .equalToSuperview()
        .offset(Constants.horizontalMargin)
    }
    
    addSubview(folderTitleLabel)
    
    folderTitleLabel.snp.makeConstraints { make in
      make.horizontalEdges
        .equalToSuperview()
        .inset(Constants.horizontalMargin)
      make.top
        .equalTo(folderImageView.snp.bottom)
        .offset(Constants.horizontalMargin)
    }
    
    addSubview(objectsCountLabel)
    
    objectsCountLabel.snp.makeConstraints { make in
      make.horizontalEdges
        .equalToSuperview()
        .inset(Constants.horizontalMargin)
      make.top.equalTo(folderTitleLabel.snp.bottom)
        .offset(5)
    }
  }
}
