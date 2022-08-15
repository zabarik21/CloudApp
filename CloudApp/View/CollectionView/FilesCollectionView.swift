//
//  FilesCollectionView.swift
//  CollectionViewTest
//
//  Created by Timofey on 14/8/22.
//

import Foundation
import UIKit
import RxRelay

enum FoldersSection: Int {
  case Folders
}

enum FilesSection: Int {
  case files
}

class FilesCollectionView: UICollectionView {
  
  typealias Snapshot = NSDiffableDataSourceSnapshot<FilesSection, FileCellViewModel>

  
  var viewModels: [FileCellViewModel] = [] {
    didSet {
      self.applySnapshot()
    }
  }
  public var fileTapRelay = PublishRelay<String>()
  // Datasource properties
  private var diffableDataSource: UICollectionViewDiffableDataSource<FilesSection, FileCellViewModel>!
  // State properties
  private var layoutType: LayoutType
  
  init(layout: LayoutType) {
    self.layoutType = layout
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    setupCollectionView()
    setupDataSource()
    delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - CollectionViewDelegate
extension FilesCollectionView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let fileName = viewModels[indexPath.row].filename
    fileTapRelay.accept(fileName)
  }
}

// MARK: - Setup DataSource
extension FilesCollectionView {
  
  private func setupDataSource() {
    diffableDataSource = UICollectionViewDiffableDataSource(collectionView: self, cellProvider: { collectionView, indexPath, itemIdentifier in
      guard let section = FilesSection(rawValue: indexPath.section) else {
        fatalError("Uknown section")
      }
      
      switch section {
      case .files:
        switch self.layoutType {
        case .grid:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FileColumnCell.reuseId, for: indexPath) as? FileColumnCell else {
            return UICollectionViewCell()
          }
          cell.viewModel = self.viewModels[indexPath.row]
          return cell
        case .list:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FileListCell.reuseId, for: indexPath) as? FileListCell else {
            return UICollectionViewCell()
          }
          cell.viewModel = self.viewModels[indexPath.row]
          return cell
        }
        
      }
    })
  }
  
  func applySnapshot() {
    DispatchQueue.main.async {
      var snapshot = Snapshot()
      snapshot.appendSections([.files])
      snapshot.appendItems(self.viewModels, toSection: .files)
      self.diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
  }
  
}

// MARK: - Setup Layout
extension FilesCollectionView {
  
  private func setupCollectionView() {
    collectionViewLayout = createLayout()
    backgroundColor = .clear
    showsVerticalScrollIndicator = false
    showsHorizontalScrollIndicator = false
    autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    register(FileColumnCell.self, forCellWithReuseIdentifier: FileColumnCell.reuseId)
    register(FileListCell.self, forCellWithReuseIdentifier: FileListCell.reuseId)
    setupDataSource()
  }
  
  private func createLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout(sectionProvider: { section, envieroment in
      guard let section = FilesSection(rawValue: section) else {
        fatalError("Uknown section")
      }
      switch section {
      case .files:
        return LayoutFactory.shared.getFilesLayout(for: self.layoutType)
      }
    })
    return layout
  }
  
  func changeLayout(to type: LayoutType) {
    DispatchQueue.main.async {
      self.layoutType = type
      self.collectionViewLayout.invalidateLayout()
      self.reloadData()
    }
  }
}
