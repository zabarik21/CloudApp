//
//  FolderListCell.swift
//  CollectionViewTest
//
//  Created by Timofey on 13/8/22.
//

import Foundation
import UIKit

class FolderListCell: UICollectionViewCell, ReuseIdProtocol {
  
  private enum Constants {
    static let folderImageName = "folder.fill"
    static let imageCornerRadius: CGFloat = 10
    static let topMargin: CGFloat = 5
  }
  
  static var reuseId: String = "FolderListCell"
  
  private var foldernameLabel: UILabel!
  private var objectsCountLabel: UILabel!
  private var folderImageView: UIImageView!
  
  var viewModel: FolderCellViewModel? {
    didSet {
      self.udpateUI(with: viewModel)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupElements()
  }
  
  func udpateUI(with viewModel: FolderCellViewModel?) {
    DispatchQueue.main.async {
      self.foldernameLabel.text = viewModel?.name
      self.objectsCountLabel.text = "Uknown objects count"
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: SetupUI
extension FolderListCell {
  
  private func setupElements() {
    setupLabels()
    setupImageView()
    setupConstraints()
  }
  
  private func setupLabels() {
    foldernameLabel = UILabel(
      text: "Folder name",
      fontSize: 16,
      weight: .bold,
      textColor: .white
    )
    foldernameLabel.lineBreakMode = .byTruncatingMiddle
    foldernameLabel.textAlignment = .left
    
    objectsCountLabel = UILabel(
      text: "13 Objects",
      fontSize: 14,
      weight: .bold,
      textColor: .darkTextColor
    )
    objectsCountLabel.textAlignment = .left
  }
  
  private func setupImageView() {
    folderImageView = UIImageView()
    folderImageView.contentMode = .center
    let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .light, scale: .small)
    folderImageView.image = UIImage(
      systemName: Constants.folderImageName,
      withConfiguration: config
    )

    folderImageView.tintColor = .fileIconColor
    folderImageView.layer.cornerRadius = Constants.imageCornerRadius
    folderImageView.layer.backgroundColor = UIColor.cellBackgroundColor.cgColor
  }
  
  private func setupConstraints() {
    let height = self.bounds.height
    
    addSubview(folderImageView)
    
    folderImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.centerY.equalToSuperview()
      make.width.height.equalTo(height - Constants.topMargin * 2)
    }
    
    let labelsStackView = UIStackView(arrangedSubviews: [
      foldernameLabel,
      objectsCountLabel
    ])
    labelsStackView.axis = .vertical
    labelsStackView.alignment = .leading
    labelsStackView.distribution = .equalSpacing
    
    addSubview(labelsStackView)
    
    labelsStackView.snp.makeConstraints { make in
      make.leading
        .equalTo(folderImageView.snp.trailing)
        .offset(15)
      make.trailing
        .equalToSuperview()
        .offset(15)
      make.height
        .equalTo(folderImageView)
        .offset(-(Constants.topMargin * 2))
      make.centerY.equalToSuperview()
    }
    
  }
}
  
