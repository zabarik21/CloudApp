//
//  ViewController.swift
//  CollectionViewTest
//
//  Created by Timofey on 12/8/22.
//

import UIKit
import SnapKit
import RxSwift
import Photos
import PhotosUI


protocol MainFolderViewProtocol: UIViewController, PHPickerViewControllerDelegate, UIDocumentPickerDelegate {
  var router: MainFolderRouter? { get set }
  var coordinator: RootFolderCoordinatorProtocol? { get set }
}

class MainFolderViewController: UIViewController, MainFolderViewProtocol {
  
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
  
  var router: MainFolderRouter?
  var coordinator: RootFolderCoordinatorProtocol?
  
  private let bag = DisposeBag()
  
  private var folderOpened = false
  
  private var layoutType: LayoutType = UserDefaultsService.shared.getLayoutType() {
    didSet {
      UserDefaultsService.shared.setLayout(to: layoutType)
      changeLayout(to: layoutType)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    folderOpened = false
    layoutType = UserDefaultsService.shared.getLayoutType()
    layoutSwitchView.switchTo(layoutType: layoutType)
  }
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .mainBg
    setupElements()
    setupObservers()
  }
  
  private func setupObservers() {
    setupfolderFileActionViewObserver()
    foldersCollectionViewController.openFolderRelay.subscribe(onNext: { [unowned self] foldername in
      self.openFolder(foldername: foldername)
    })
      .disposed(by: bag)
    layoutSwitchView.switchRelay.subscribe(onNext: { [unowned self] type in
      self.layoutType = type
    })
      .disposed(by: bag)
  }
  
  private func setupfolderFileActionViewObserver() {
    FolderFileActionView.eventRelay
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [unowned self] eventType in
      switch eventType {
      case .createFolder:
        self.tryCreateFolder()
      case .addFile:
        self.tryAddFileFromFilesManager()
      case .addMedia:
        self.tryAddFileFromGallery()
      }
    })
      .disposed(by: bag)
  }
  
  func openFolder(foldername: String) {
    folderOpened = true
    coordinator?.openFiles(with: foldername, layoutType: self.layoutType)
  }
  
}

// MARK: - FolderFileActions
extension MainFolderViewController {
  
  private func tryCreateFolder() {
    guard !self.folderOpened else {
      if let filesViewController = self.navigationController?.topViewController as? FilesViewController {
        filesViewController.tryCreateFolder()
      }
      return
    }
    let alertController = AlertFactory.getCreateFolderAlert(createAction: { [weak self] folderName in
      self?.createFolder(foldername: folderName)
    })
    self.present(alertController, animated: true)
  }
  
  private func createFolder(foldername: String) {
    guard !self.folderOpened else {
      return
    }
    foldersCollectionViewController.output.send(.createFolder(foldername: foldername))
  }
  
  private func tryAddFileFromFilesManager() {
    router?.presentFiles()
  }
  
  private func tryAddFileFromGallery() {
    router?.presentPhotos()
  }
  
}

// MARK: - Photos picker delegate
extension MainFolderViewController: PHPickerViewControllerDelegate {
  
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    DispatchQueue.main.async {
      for result in results {
        if let topViewController = self.navigationController?.topViewController as? FilesViewController {
          topViewController.tryAddPhotoResult(result)
        } else {
          self.filesCollectionViewController.output.send(.addFromGallery(result: result))
        }
      }
    }
  }
  
}
// MARK: - Dockument picker delegate
extension MainFolderViewController: UIDocumentPickerDelegate {
  
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let docUrl = urls.first else { return }
    guard docUrl.pathExtension != "txt" else {
      self.showErrorAlert("Forbidden file type")
      return
    }
    guard docUrl.startAccessingSecurityScopedResource() else { return }
    DispatchQueue.main.async {
      if let topViewController = self.navigationController?.topViewController as? FilesViewController {
        topViewController.tryAddFile(docUrl)
      } else {
        self.filesCollectionViewController.output.send(.addFromFiles(url: docUrl))
      }
    }
  }
  
}
// MARK: - Search bar delegate
extension MainFolderViewController: UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    foldersCollectionViewController.output.send(.filterFolders(text: searchText))
    filesCollectionViewController.output.send(.filterFiles(text: searchText))
  }
  
}

// MARK: - SetupUI
extension MainFolderViewController {
  
  private func setupElements() {
    setupSearchBar()
    setupLabels()
    setupCollections()
    setupLayoutView()
    setupConstraints()
  }
  
  fileprivate func setupCollections() {
    let folderViewModels = FoldersViewModel(foldersStorage: FirebaseStorageService.shared)
    foldersCollectionViewController = FoldersCollectionViewController(viewModel: folderViewModels, layoutType: layoutType)
    let filesViewModel = FilesListViewModel(storageService: FirebaseStorageService.shared)
    filesCollectionViewController = FilesCollectionViewController(viewModel: filesViewModel, layoutType: layoutType)
  }
  
  fileprivate func setupLayoutView() {
    layoutSwitchView = LayoutSwitcherView(type: layoutType)
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

// MARK: - LayoutSwitcherAction
extension MainFolderViewController {
  
  private func changeLayout(to type: LayoutType) {
    filesCollectionViewController.changeLayout(to: type)
    foldersCollectionViewController.changeLayout(to: type)
  }
  
}
