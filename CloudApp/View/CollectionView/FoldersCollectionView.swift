//
//  FoldersCollectionView.swift
//  CollectionViewTest
//
//  Created by Timofey on 14/8/22.
//

import Foundation
import UIKit
import RxRelay


enum FolderSection: Int {
  case folders
}

class FoldersCollectionView: UICollectionView {
  
  typealias Snapshot = NSDiffableDataSourceSnapshot<FolderSection, FolderCellViewModel>
  
  var viewModels: [FolderCellViewModel] = [] {
    didSet {
      self.applySnapshot()
    }
  }
  
  public var folderTapRelay = PublishRelay<String>()
  
  // Datasource properties
  private var diffableDataSource: UICollectionViewDiffableDataSource<FolderSection, FolderCellViewModel>!
  private var snapshot: NSDiffableDataSourceSnapshot<FolderSection, FolderCellViewModel>!
  // State properties
  private var layoutType: LayoutType
  
  init(layout type: LayoutType) {
    self.layoutType = type
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    setupCollectionView()
    setupDataSource()
    self.delegate = self
  }
  
  func changeLayout(to type: LayoutType) {
    DispatchQueue.main.async {
      self.layoutType = type
      self.collectionViewLayout.invalidateLayout()
      self.reloadData()
    }
  }
  
  func applySnapshot() {
    DispatchQueue.main.async {
      var snapshot = Snapshot()
      snapshot.appendSections([.folders])
      snapshot.appendItems(self.viewModels, toSection: .folders)
      self.diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Setup DataSource
extension FoldersCollectionView {
  
  private func setupDataSource() {
    snapshot = NSDiffableDataSourceSnapshot<FolderSection, FolderCellViewModel>()
    snapshot.appendSections([.folders])
    
    diffableDataSource = UICollectionViewDiffableDataSource(collectionView: self, cellProvider: { collectionView, indexPath, itemIdentifier in
      switch self.layoutType {
      case .grid:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderColumnCell.reuseId, for: indexPath) as? FolderColumnCell else { return UICollectionViewCell()
        }
        cell.viewModel = self.viewModels[indexPath.row]
        return cell
      case .list:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderListCell.reuseId, for: indexPath) as? FolderListCell else { return UICollectionViewCell()
        }
        cell.viewModel = self.viewModels[indexPath.row]
        return cell
      }
    })
  }
  
}
// MARK: - Delegate
extension FoldersCollectionView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let filename = viewModels[indexPath.row].name
    folderTapRelay.accept(filename)
  }
}
// MARK: - Setup Layout

extension FoldersCollectionView {
  
  private func setupCollectionView() {
    collectionViewLayout = createLayout()
    backgroundColor = .clear
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false
    autoresizingMask = [.flexibleWidth, .flexibleHeight]
    alwaysBounceVertical = false
    register(FolderListCell.self, forCellWithReuseIdentifier: FolderListCell.reuseId)
    register(FolderColumnCell.self, forCellWithReuseIdentifier: FolderColumnCell.reuseId)
    DispatchQueue.main.async {
      self.collectionViewLayout.invalidateLayout()
    }
  }
  
  private func createLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout(sectionProvider: { section, envieroment in
      guard let section = FolderSection(rawValue: section) else {
        fatalError("Uknown section")
      }
      switch section {
      case .folders:
        return LayoutFactory.shared.getFoldersLayout(for: self.layoutType)
      }
    })
    return layout
  }
  
}
