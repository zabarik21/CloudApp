//
//  LayoutFactory.swift
//  CollectionViewTest
//
//  Created by Timofey on 13/8/22.
//

import Foundation
import UIKit


class LayoutFactory {
  static let shared = LayoutFactory()
  
  private init() {}
  
  func getFilesLayout(for type: LayoutType) -> NSCollectionLayoutSection {
    switch type {
    case .grid:
      return createColumnVerticalLayout()
    case .list:
      return createListVerticalLayout()
    }
  }
  
  func getFoldersLayout(for type: LayoutType) -> NSCollectionLayoutSection {
    switch type {
    case .grid:
      return createColumnHorizontalLayout()
    case .list:
      return createListVerticalLayout()
    }
  }
  
  private func createColumnHorizontalLayout() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalHeight(1)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalHeight(1),
      heightDimension: .fractionalHeight(1)
    )
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item]
    )
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuous
    section.contentInsets = NSDirectionalEdgeInsets(
      top: 20,
      leading: 0,
      bottom: 0,
      trailing: 0)
    section.interGroupSpacing = 15
    
    
    return section

  }
  
  private func createListVerticalLayout() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalHeight(1)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 12
    section.contentInsets = NSDirectionalEdgeInsets(
      top: 20,
      leading: 0,
      bottom: 20,
      trailing: 0
    )
    return section
  }
  
  private func createColumnVerticalLayout() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1 / 2),
      heightDimension: .fractionalWidth(1 / 2)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(
      top: 0,
      leading: 5,
      bottom: 0,
      trailing: 5
    )
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(170))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 10
    section.contentInsets = NSDirectionalEdgeInsets(
      top: 20,
      leading: 0,
      bottom: 20,
      trailing: 0
    )
    
    return section
  }
  
}
