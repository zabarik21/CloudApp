//
//  FileListCell.swift
//  CollectionViewTest
//
//  Created by Timofey on 13/8/22.
//

import Foundation
import UIKit


class FileListCell: UICollectionViewCell, ReuseIdProtocol {
  
  private enum Constants {
    static let cellCornerRadius: CGFloat = 20
    static let imageCornerRadius: CGFloat = 10
    static let fileImageName = "doc.fill"
    static let topMargin: CGFloat = 5
  }
  
  static var reuseId: String {
    return String(describing: self)
  }
  
  private var filenameLabel: UILabel!
  private var fileextImageView: UIImageView!
  
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
      self.filenameLabel.text = viewModel?.filename
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
    filenameLabel = UILabel(
      text: "Filename",
      fontSize: 16,
      weight: .bold,
      textColor: .white
    )
    filenameLabel.lineBreakMode = .byTruncatingMiddle
  }
  
  private func setupImageView() {
    fileextImageView = UIImageView()
    fileextImageView.contentMode = .center
    let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .light, scale: .small)
    fileextImageView.image = UIImage(
      systemName: Constants.fileImageName,
      withConfiguration: config
    )

    fileextImageView.tintColor = .fileIconColor
    fileextImageView.layer.cornerRadius = Constants.imageCornerRadius
    fileextImageView.layer.backgroundColor = UIColor.cellBackgroundColor.cgColor
  }
  
  private func setupConstraints() {
    let height = self.bounds.height
    
    addSubview(fileextImageView)
    
    fileextImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.centerY.equalToSuperview()
      make.width.height.equalTo(height - Constants.topMargin * 2)
    }
    
    addSubview(filenameLabel)
    
    filenameLabel.snp.makeConstraints { make in
      make.leading
        .equalTo(fileextImageView.snp.trailing)
        .offset(Constants.topMargin * 3)
      make.centerY.equalToSuperview()
    }
  }
}
