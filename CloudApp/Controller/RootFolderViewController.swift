//
//  ViewController.swift
//  CollectionViewTest
//
//  Created by Timofey on 12/8/22.
//

import UIKit
import SnapKit
import RxSwift

class RootFolderViewController: UIViewController {
  
  enum Constants {
    static let horizontalMarginMult: CGFloat = 0.05
    static let foldersViewHeightMult: CGFloat = 0.24
  }
  
  private var searchBar: UISearchBar!
  private var layoutSwitchView: LayoutSwitcherView!
  private var foldersCollectionViewController: FoldersCollectionViewController!
  private var filesCollectionViewController: FilesCollectionViewController!
  private var foldersLabel: UILabel!
  private var filesLabel: UILabel!
  
  private let bag = DisposeBag()
  
  private var folderOpened = false
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    folderOpened = false
    layoutType = UserDefaultsService.shared.getLayoutType()
    layoutSwitchView.switchTo(layoutType: layoutType)
  }
  
  private var layoutType: LayoutType = UserDefaultsService.shared.getLayoutType() {
    didSet {
      UserDefaultsService.shared.setLayout(to: layoutType)
      changeLayout(to: layoutType)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .mainBg
    setupElements()
    setupObservers()
  }
  
  private func setupObservers() {
    setupfolderFileActionViewObserver()
    foldersCollectionViewController.openFolderRelay.subscribe(onNext: { [weak self] foldername in
      self?.openFolder(foldername: foldername)
    })
  }
  
  private func setupfolderFileActionViewObserver() {
    FolderFileActionView.eventRelay.subscribe(onNext: { [weak self] eventType in
      switch eventType {
      case .createFolder:
        self?.tryCreateFolder()
      case .addFile:
        self?.tryAddFileFromFilesManager()
      case .addMedia:
        self?.tryAddFileFromGallery()
      }
    })
      .disposed(by: bag)
  }
  
  func openFolder(foldername: String) {
    folderOpened = true
    DispatchQueue.main.async {
      let filesVC = FilesViewController(foldername: foldername, layoutType: self.layoutType)
      self.navigationController?.pushViewController(filesVC, animated: true)
    }
  }
  
}

// MARK: - FolderFileActions
extension RootFolderViewController {
  
  func tryCreateFolder() {
    guard !self.folderOpened else { return }
    DispatchQueue.main.async {
      let alertController = AlertFactory.getCreateFolderAlert(createAction: { folderName in
        print("create folder with name \(folderName)")
      })
      self.present(alertController, animated: true)
    }
  }
  
  func createFolder(foldername: String) {
    print(foldername)
  }
  
  func tryAddFileFromFilesManager() {
    guard !self.folderOpened else { return }
    print(#function)
  }
  
  func tryAddFileFromGallery() {
    guard !self.folderOpened else { return }
    print(#function)
  }
  
}
// MARK: - Search bar delegate
extension RootFolderViewController: UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    foldersCollectionViewController.output.send(.filterFolders(text: searchText))
    filesCollectionViewController.output.send(.filterFiles(text: searchText))
  }
  
}

// MARK: - SetupUI
extension RootFolderViewController {
  
  private func setupElements() {
    setupSearchBar()
    setupLabels()
    setupCollections()
    setupLayoutView()
    setupConstraints()
  }
  
  fileprivate func setupCollections() {
    foldersCollectionViewController = FoldersCollectionViewController(viewModel: FoldersViewModel(), layoutType: layoutType)
    filesCollectionViewController = FilesCollectionViewController(viewModel: FilesListViewModel(foldername: ""), layoutType: layoutType)
  }
  
  fileprivate func setupLayoutView() {
    layoutSwitchView = LayoutSwitcherView(type: layoutType)
    layoutSwitchView.switchRelay.subscribe(onNext: { [weak self] type in
      self?.changeLayout(to: type)
    })
      .disposed(by: bag)
  }
  
  private func setupLabels() {
    foldersLabel = UILabel(
      text: "Folders",
      fontSize: 16,
      weight: .bold,
      textColor: .white
    )
    filesLabel = UILabel(
      text: "Files",
      fontSize: 16,
      weight: .bold,
      textColor: .white
    )
  }
  
  private func setupSearchBar() {
    searchBar = UISearchBar()
    searchBar.delegate = self
    searchBar.sizeToFit()
    searchBar.placeholder = "Find in Root Folder"
    searchBar.searchTextField.leftView?.tintColor = .white
    searchBar.searchTextField.textColor = .white
    self.navigationItem.titleView = searchBar
  }
  
  private func setupConstraints() {
    let width = view.bounds.width
    let height = view.bounds.height
    
    view.addSubview(foldersLabel)
    
    foldersLabel.snp.makeConstraints { make in
      make.horizontalEdges
        .equalToSuperview()
        .offset(width * Constants.horizontalMarginMult)
      make.top.equalTo(view.safeAreaLayoutGuide)
        .offset(30)
    }
    
    view.addSubview(layoutSwitchView)
    
    layoutSwitchView.snp.makeConstraints { make in
      make.centerY.equalTo(foldersLabel)
      make.width.equalTo(103)
      make.height.equalTo(23)
      make.trailing
        .equalToSuperview()
        .offset(-Constants.horizontalMarginMult * width)
    }
    
    view.addSubview(foldersCollectionViewController.view)
    
    foldersCollectionViewController.view.snp.makeConstraints { make in
      make.horizontalEdges
        .equalToSuperview()
        .inset(width * Constants.horizontalMarginMult)
      make.top
        .equalTo(foldersLabel.snp.top)
        .inset(20)
      make.height.equalTo(Constants.foldersViewHeightMult * height)
    }
    
    view.addSubview(filesLabel)
    
    filesLabel.snp.makeConstraints { make in
      make.top
        .equalTo(foldersCollectionViewController.view.snp.bottom)
        .offset(30)
      make.horizontalEdges
        .equalToSuperview()
        .offset(width * Constants.horizontalMarginMult)
      
    }
    
    view.addSubview(filesCollectionViewController.view)
    
    filesCollectionViewController.view.snp.makeConstraints { make in
      make.horizontalEdges
        .equalToSuperview()
        .inset(width * Constants.horizontalMarginMult)
      make.top
        .equalTo(filesLabel.snp.top)
        .inset(20)
      make.bottom.equalToSuperview()
    }
  }
  
}

// MARK: - LayoutSwitchDelegate
extension RootFolderViewController: LayoutSwitcherViewDelegate {
  
  private func changeLayout(to type: LayoutType) {
    self.filesCollectionViewController.changeLayout(to: type)
    self.foldersCollectionViewController.changeLayout(to: type)
  }
  
  func sliderSwitched(to type: LayoutType) {
    self.layoutType = type
  }
  
}