//
//  NavigationController.swift
//  CollectionViewTest
//
//  Created by Timofey on 15/8/22.
//

import Foundation
import UIKit


 
class NavigationController: UINavigationController {
  
  private var myView: FolderFileActionView = FolderFileActionView()
//  private var searchBar: UISearchBar!
  private var searchController: UISearchController!
  
  init(rootViewController: MainFolderViewController) {
    super.init(rootViewController: rootViewController)
    setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}


// MARK: - Setup UI
extension NavigationController {
  private func setupUI() {
    setupNavigationBar()
    setupConstraints()
  }
  
  private func setupConstraints() {
    view.addSubview(myView)
    
    myView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupNavigationBar() {
    navigationBar.tintColor = .lightTextColor
  }
  
}

