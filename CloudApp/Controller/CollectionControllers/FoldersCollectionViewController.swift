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
  var output: Output<FoldersViewEvent> = Output()
  typealias ViewModelEvent = FoldersViewModelEvent
  typealias ViewEvent = FoldersViewEvent
  // UI
  private var foldersCollecetion: FoldersCollectionView!
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
    foldersCollecetion.folderTapRelay.subscribe(onNext: { [weak self] foldername in
      self?.output.send(.folderTouched(foldername: foldername))
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
    foldersCollecetion = FoldersCollectionView(layout: layoutType)
    view.addSubview(foldersCollecetion)
    foldersCollecetion.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
// MARK: - Handle ViewModel events
extension FoldersCollectionViewController {
  
  func setupBindings() {
    self.output.handlers.append(viewModel.handle)
    viewModel.output.handlers.append(handle)
  }
  
  func handle(event: FoldersViewModelEvent) {
    switch event {
    case .updateFoldersViewModels(let viewModels):
      self.foldersCollecetion.viewModels = viewModels
    case .openFolder(let foldername):
      self.openFolderRelay.accept(foldername)
    case .showAlert(title: let title, message: let message):
      self.showAlert(title, message)
    }
  }
  
  func showAlert(_ title: String, _ message: String) {
    DispatchQueue.main.async {
      let alert = AlertFactory.getErrorAlert(title: title, message: message)
      self.present(alert, animated: true)
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

