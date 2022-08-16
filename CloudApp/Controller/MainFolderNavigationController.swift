//
//  NavigationController.swift
//  CollectionViewTest
//
//  Created by Timofey on 15/8/22.
//

import Foundation
import UIKit


 
class MainFolderNavigationController: UINavigationController {
  
  private var myView: FolderFileActionView = FolderFileActionView()
  private var searchController: UISearchController!
  
  init() {
    super.init(rootViewController: MainFolderViewController())
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}


// MARK: - Setup UI
extension MainFolderNavigationController {
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

