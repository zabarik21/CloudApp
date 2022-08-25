//
//  FoldersCollectionViewController.swift
//  CloudApp
//
//  Created by Timofey on 15/8/22.
//

import Foundation
import UIKit
import RxSwift
import RxRelay


class FoldersCollectionViewController: UIViewController, ViewModelContainer {
  
  // rx
  private let bag = DisposeBag()
  public var openFolderRelay = PublishRelay<String>()
  // ViewModel
  public var viewModel: FoldersViewModel
  public var output: Output<FoldersViewEvent> = Output()
  typealias ViewModelEvent = FoldersViewModelEvent
  typealias ViewEvent = FoldersViewEvent
  // UI
  private var foldersCollecetion: FoldersCollectionView!
  private var activityIndicator: UIActivityIndicatorView!
  private var layoutType: LayoutType
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    layoutType =  UserDefaultsService.shared.getLayoutType()
  }
  
  init(viewModel: FoldersViewModel, layoutType type: LayoutType) {
    self.viewModel = viewModel
    self.layoutType = type
    super.init(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupObserver()
    setupBindings()
    output.send(.viewLoaded)
    viewModel.start()
  }
  
  private func setupObserver() {
    foldersCollecetion.folderTapObservable.subscribe(onNext: { [unowned self] indexPath in
      self.output.send(.folderTouchedAt(indexPath: indexPath))
    })
      .disposed(by: bag)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
// MARK: - Setup UI
extension FoldersCollectionViewController {
  
  private func setupUI() {
    setupActivityIndicator()
    setupFolders()
    setupConstraints()
  }
  
  private func setupConstraints() {
    
    view.addSubview(foldersCollecetion)
    foldersCollecetion.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    view.addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { make in
      make.centerY.centerX.equalToSuperview()
    }
  }
  
  private func setupFolders() {
    foldersCollecetion = FoldersCollectionView(layout: layoutType)
  }
  
  private func setupActivityIndicator() {
    activityIndicator = UIActivityIndicatorView(style: .medium)
    activityIndicator.color = .white
    activityIndicator.hidesWhenStopped = true
  }
  
}
// MARK: - Handle ViewModel events
extension FoldersCollectionViewController {
  
  func setupBindings() {
    output.handlers.append(viewModel.handle)
    viewModel.output.handlers.append(handle)
  }
  
  func handle(event: FoldersViewModelEvent) {
    switch event {
    case .updateFoldersViewModels(let viewModels):
      self.foldersCollecetion.viewModels = viewModels
    case .openFolder(let foldername):
      self.openFolderRelay.accept(foldername)
    case .showAlert(title: let title, message: let message):
      self.showDefaultAlert(title, message)
    case .startActivityIndicator:
      self.turnActivityIndicator(on: true)
    case .stopActivityIndicator:
      self.turnActivityIndicator(on: false)
    case .scrollToFolder(foldername: let foldername):
      self.scrollToFolder(foldername)
    }
  }
  
  func scrollToFolder(_ foldername: String) {
    foldersCollecetion.scrollToFolder(foldername: foldername)
  }
  
  func turnActivityIndicator(on: Bool) {
    DispatchQueue.main.async {
      if on {
        self.activityIndicator.startAnimating()
      } else {
        self.activityIndicator.stopAnimating()
      }
    }
  }
  
  func changeLayout(to type: LayoutType) {
    DispatchQueue.main.async {
      UserDefaultsService.shared.setLayout(to: type)
      self.layoutType = type
      self.foldersCollecetion.changeLayout(to: type)
    }
  }
  
}

