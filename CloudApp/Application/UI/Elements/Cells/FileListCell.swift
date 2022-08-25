//
//  FileListCell.swift
//  CollectionViewTest
//
//  Created by Timofey on 13/8/22.
//

import Foundation
import UIKit


class FileListCell: UICollectionViewCell, ReuseIdProtocol, FileCellProtocol {
  
  private enum Constants {
    static let cellCornerRadius: CGFloat = 20
    static let imageCornerRadius: CGFloat = 10
    static let topMargin: CGFloat = 5
    static let imagePointSize: CGFloat = 36
  }
  
  static var reuseId: String {
    return String(describing: self)
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
extension FileListCell {
  
  private func setupElements() {
    setupLabels()
    setupImageView()
    setupConstraints()
  }
  
  private func setupLabels() {
    fileTitleLabel = UILabel(
      text: "Filename",
      fontSize: 16,
      weight: .bold,
      textColor: .white
    )
    fileTitleLabel.lineBreakMode = .byTruncatingMiddle
  }
  
  private func setupImageView() {
    fileImageView = UIImageView()
    fileImageView.contentMode = .center
    let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .light, scale: .small)
    fileImageView.image = UIImage(
      systemName: FileCellImageConstants.fileImageName,
      withConfiguration: config
    )

    fileImageView.tintColor = .fileIconColor
    fileImageView.layer.cornerRadius = Constants.imageCornerRadius
    fileImageView.layer.backgroundColor = UIColor.cellBackgroundColor.cgColor
  }
  
  private func setupConstraints() {
    let height = self.bounds.height
    
    addSubview(fileImageView)
    
    fileImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.centerY.equalToSuperview()
      make.width.height.equalTo(height - Constants.topMargin * 2)
    }
    
    addSubview(fileTitleLabel)
    
    fileTitleLabel.snp.makeConstraints { make in
      make.leading
        .equalTo(fileImageView.snp.trailing)
        .offset(Constants.topMargin * 3)
      make.trailing
        .equalToSuperview()
        .offset(-Constants.topMargin * 3)
      make.centerY.equalToSuperview()
    }
  }
}
