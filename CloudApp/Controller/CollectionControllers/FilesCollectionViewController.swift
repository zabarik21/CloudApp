//
//  FilesCollectionViewController.swift
//  CloudApp
//
//  Created by Timofey on 15/8/22.
//

import Foundation
import UIKit
import RxSwift

class FilesCollectionViewController: UIViewController, ViewModelContainer {
  
  // rx
  private let bag = DisposeBag()
  // ViewModel
  typealias ViewModelEvent = FilesViewModelEvent
  typealias ViewEvent = FilesViewEvent
  var output: Output<FilesViewEvent> = Output()
  public var viewModel: FilesListViewModel
  // UI
  private var filesCollection: FilesCollectionView!
  private var layoutType: LayoutType
  private var activityIndicator: UIActivityIndicatorView!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    layoutType =  UserDefaultsService.shared.getLayoutType()
  }
  
  
  init(viewModel: FilesListViewModel, layoutType type: LayoutType) {
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
  }
  
  private func setupObserver() {
    filesCollection.fileTapRelay.subscribe(onNext: { [weak self] filename in
      self?.output.send(.fileTouched(filename: filename))
    })
      .disposed(by: bag)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
// MARK: - Setup UI
extension FilesCollectionViewController {
  
  private func setupUI() {
    setupActivityIndicator()
    filesCollection = FilesCollectionView(layout: layoutType)
    setupConstraints()
  }
  
  private func setupActivityIndicator() {
    activityIndicator = UIActivityIndicatorView(style: .large)
    activityIndicator.hidesWhenStopped = true
    activityIndicator.color = .white
  }
  
  private func setupConstraints() {
    view.addSubview(filesCollection)
    
    filesCollection.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    view.addSubview(activityIndicator)
    
    activityIndicator.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
}
// MARK: - Handling ViewModel Events
extension FilesCollectionViewController {
  
  func setupBindings() {
    viewModel.output.handlers.append(handle)
    output.handlers.append(viewModel.handle)
    viewModel.start()
  }
  
  func handle(event: FilesViewModelEvent) {
    switch event {
    case .updateFilesViewModels(let viewModels):
      self.filesCollection.viewModels = viewModels
    case .showFileOptionsAlert(filename: let filename):
      self.showFileOptionsAlert(filename: filename)
    case .showRenameFileAlert(filename: let filename):
      self.showRenameFileAlert(filename: filename)
    case .renameFileTouched(filename: let filename):
      self.showRenameFileAlert(filename: filename)
    case .changeLayout(type: let type):
      self.changeLayout(to: type)
    case .showErrorAlert(message: let message):
      self.showErrorAlert(message)
    case .showDefaultAlert(title: let title, message: let message):
      self.showDefaultAlert(title, message)
    case .startActivityIndicator:
      self.turnActivityIndicator(on: true)
    case .stopActivityIndicator:
      self.turnActivityIndicator(on: false)
    }
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
  
  private func showRenameFileAlert(filename: String) {
    DispatchQueue.main.async { [weak self] in
      let alert = AlertFactory.getRenameFileAlert { newFilename in
        self?.output.send(.renameFileApproved(oldFilename: filename, newFilename: newFilename))
      }
      self?.present(alert, animated: true)
    }
  }
  
  private func showFileOptionsAlert(filename: String) {
    DispatchQueue.main.async { [weak self] in
      let alert = AlertFactory.getFilesActionAlert(
        filename: filename) {
          self?.output.send(.downloadFileTouched(filename: filename))
        } renameAction: {
          self?.output.send(.renameFileTouched(filename: filename))
        } deleteAction: {
          self?.output.send(.deleteFileTouched(filename: filename))
        }
      self?.present(alert, animated: true)
    }
  }
  
  func changeLayout(to type: LayoutType) {
    DispatchQueue.main.async {
      UserDefaultsService.shared.setLayout(to: type)
      self.layoutType = type
      self.filesCollection.changeLayout(to: type)
    }
  }
  
}

