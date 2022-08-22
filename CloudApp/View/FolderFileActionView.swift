//
//  FolderFileActionView.swift
//  CloudApp
//
//  Created by Timofey on 15/8/22.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxRelay


enum FolderFileActionEvent {
  case createFolder
  case addFile
  case addMedia
}

class FolderFileActionView: UIView {
  
  private enum Constants {
    static let buttonHeight: CGFloat = 80
    static let edgeMargin: CGFloat = 30
    static let animDuration: CGFloat = 0.3
    static let filesImageName = "doc.fill"
    static let photoImageName = "photo"
    static let folderImageName = "folder.fill.badge.plus"
    static let plusImageName = "plus"
  }
  
  static let eventRelay = PublishRelay<FolderFileActionEvent>()
  private let bag = DisposeBag()
  
  private var blurView: UIVisualEffectView!
  private var mainBtn: UIButton!
  private var addFromFilesBtn: UIButton!
  private var addFolderBtn: UIButton!
  private var addFromPhotoBtn: UIButton!
  private var filesLabel: UILabel!
  private var photoLabel: UILabel!
  private var folderLabel: UILabel!
  
  private var buttonsHidden = true
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let btnHeight = mainBtn.bounds.height
    mainBtn.layer.cornerRadius = btnHeight / 2
    addFromFilesBtn.layer.cornerRadius = btnHeight / 2
    addFolderBtn.layer.cornerRadius = btnHeight / 2
    addFromPhotoBtn.layer.cornerRadius = btnHeight / 2
    updateShadowPath()
  }
  
  init() {
    super.init(frame: .zero)
    setupElements()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Button hide/show
extension FolderFileActionView {
  
  private func hideButtons() {
    filesLabel.layer.opacity = 0
    folderLabel.layer.opacity = 0
    photoLabel.layer.opacity = 0
    addFromFilesBtn.layer.opacity = 0
    addFromFilesBtn.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
    addFromPhotoBtn.layer.opacity = 0
    addFromPhotoBtn.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
    addFolderBtn.layer.opacity = 0
    addFolderBtn.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
  }
  
  private func showButtons() {
    filesLabel.layer.opacity = 1
    folderLabel.layer.opacity = 1
    photoLabel.layer.opacity = 1
    addFromFilesBtn.layer.opacity = 1
    addFromFilesBtn.transform = CGAffineTransform(scaleX: 1, y: 1)
    addFromPhotoBtn.layer.opacity = 1
    addFromPhotoBtn.transform = CGAffineTransform(scaleX: 1, y: 1)
    addFolderBtn.layer.opacity = 1
    addFolderBtn.transform = CGAffineTransform(scaleX: 1, y: 1)
  }
  
  private func showView() {
    UIView.animate(withDuration: Constants.animDuration) {
      self.blurView.layer.opacity = 1
      self.mainBtn.transform = CGAffineTransform(rotationAngle: .pi / 4)
      self.mainBtn.layer.borderWidth = 5
      self.buttonsHidden.toggle()
      self.self.showButtons()
    }
  }
  
  private func hideView() {
    UIView.animate(withDuration: Constants.animDuration) {
      self.mainBtn.transform = CGAffineTransform(rotationAngle: 0)
      self.blurView.layer.opacity = 0
      self.mainBtn.layer.borderWidth = 0
      self.buttonsHidden.toggle()
      self.self.hideButtons()
    }
  }
  
}

// MARK: - Button Targets
extension FolderFileActionView {
  func setupButtonTargets() {
    mainBtn.addTarget(self, action: #selector(mainBtnTouch), for: .touchUpInside)
    addFolderBtn.addTarget(self, action: #selector(handleButtons), for: .touchUpInside)
    addFromFilesBtn.addTarget(self, action: #selector(handleButtons), for: .touchUpInside)
    addFromPhotoBtn.addTarget(self, action: #selector(handleButtons), for: .touchUpInside)
  }
  
  @objc func handleButtons(_ sender: UIButton) {
    if sender === addFolderBtn {
      FolderFileActionView.eventRelay.accept(.createFolder)
    } else if sender === addFromFilesBtn {
      FolderFileActionView.eventRelay.accept(.addFile)
    } else if sender === addFromPhotoBtn {
      FolderFileActionView.eventRelay.accept(.addMedia)
    }
    hideView()
  }
  
  @objc func mainBtnTouch() {
    if buttonsHidden {
      showView()
    } else {
      hideView()
    }
  }
  
}

// MARK: - Setup UI
extension FolderFileActionView {
  
  private func setupElements() {
    setupBlurView()
    setupButtons()
    setupLabels()
    setupButtonTargets()
    setupButtonTargets()
    setupConstraints()
  }
  
  private func setupBlurView() {
    let blurEffect = UIBlurEffect(style: .dark)
    blurView = UIVisualEffectView(effect: blurEffect)
    blurView.isUserInteractionEnabled = false
    blurView.layer.opacity = 0
  }
  
  private func setupLabels() {
    filesLabel = UILabel(
      text: "Upload from files",
      fontSize: 16,
      weight: .bold,
      textColor: .white
    )
    
    photoLabel = UILabel(
      text: "Upload from gallery",
      fontSize: 16,
      weight: .bold,
      textColor: .white
    )
    
    folderLabel = UILabel(
      text: "Create folder",
      fontSize: 16,
      weight: .bold,
      textColor: .white
    )
    
    filesLabel.layer.opacity = 0
    folderLabel.layer.opacity = 0
    photoLabel.layer.opacity = 0
  }
  
  private func setupConstraints() {
    addSubview(blurView)
    
    blurView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    addSubview(mainBtn)
    
    mainBtn.snp.makeConstraints { make in
      make.height.width.equalTo(Constants.buttonHeight)
      make.bottom.trailing
        .equalToSuperview()
        .offset(-Constants.edgeMargin)
    }
    
    let filesStack = UIStackView(
      arrangedSubviews: [
        filesLabel,
        addFromFilesBtn
      ],
      spacing: 10
    )
    
    let folderStackView = UIStackView(
      arrangedSubviews: [
        folderLabel,
        addFolderBtn
      ],
      spacing: 10
    )
    
    let photoStackView = UIStackView(
      arrangedSubviews: [
        photoLabel,
        addFromPhotoBtn
      ],
      spacing: 10,
      distribution: .equalSpacing,
      alignment: .center
    )
    
    addFolderBtn.snp.makeConstraints { make in
      make.height.width.equalTo(Constants.buttonHeight)
    }
    
    addFromPhotoBtn.snp.makeConstraints { make in
      make.height.width.equalTo(Constants.buttonHeight)
    }
    
    addFromFilesBtn.snp.makeConstraints { make in
      make.height.width.equalTo(Constants.buttonHeight)
    }
    
    let buttonsStackView = UIStackView(
      arrangedSubviews: [
        folderStackView,
        filesStack,
        photoStackView
      ],
      spacing: 30,
      axis: .vertical,
      alignment: .trailing
    )
    
    addSubview(buttonsStackView)
    
    buttonsStackView.snp.makeConstraints { make in
      make.trailing
        .equalToSuperview()
        .offset(-Constants.edgeMargin)
      make.bottom.equalTo(mainBtn.snp.top)
        .offset(-30)
    }
  }
  
  private func setupButtons() {
    let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .heavy, scale: .large)
    
    let fileImage = UIImage(systemName: Constants.filesImageName, withConfiguration: config)
    let photoImage = UIImage(systemName: Constants.photoImageName, withConfiguration: config)
    let folderImage = UIImage(systemName: Constants.folderImageName, withConfiguration: config)
    let plusImage = UIImage(systemName: Constants.plusImageName, withConfiguration: config)
    
    mainBtn = UIButton()
    addFromFilesBtn = UIButton()
    addFromPhotoBtn = UIButton()
    addFolderBtn = UIButton()
    
    mainBtn.backgroundColor = .addButtonColor
    addFolderBtn.backgroundColor = .mainBg
    addFromPhotoBtn.backgroundColor = .mainBg
    addFromFilesBtn.backgroundColor = .mainBg
    
    mainBtn.setImage(
      plusImage,
      for: .normal
    )
    addFromFilesBtn.setImage(
      fileImage,
      for: .normal
    )
    addFolderBtn.setImage(
      folderImage,
      for: .normal
    )
    addFromPhotoBtn.setImage(
      photoImage,
      for: .normal
    )
    
    mainBtn.tintColor = .white
    addFromFilesBtn.tintColor = .white
    addFolderBtn.tintColor = .white
    addFromPhotoBtn.tintColor = .white
    
    
    mainBtn.layer.borderColor = UIColor.white.cgColor
    mainBtn.layer.shadowOffset = CGSize(width: 0, height: 8)
    
    
    addFromFilesBtn.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
    addFromFilesBtn.layer.opacity = 0
    addFromPhotoBtn.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
    addFromPhotoBtn.layer.opacity = 0
    addFolderBtn.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
    addFolderBtn.layer.opacity = 0
  }
  
  private func updateShadowPath() {
    let btnBounds = mainBtn.bounds
    mainBtn.layer.shadowPath = UIBezierPath(
      roundedRect: btnBounds,
      cornerRadius: btnBounds.height / 2)
      .cgPath
  }
  
}

// MARK: - Hit behavior
extension FolderFileActionView {
  
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    if buttonsHidden {
      if mainBtn.frame.contains(point) {
        return mainBtn
      } else {
        return nil
      }
    } else {
      return super.hitTest(point, with: event)
    }
  }

}
