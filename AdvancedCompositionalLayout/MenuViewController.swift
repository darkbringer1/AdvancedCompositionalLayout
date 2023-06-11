//
//  MenuViewController.swift
//  AdvancedCompositionalLayout
//
//  Created by Ahmed Tarık Bozyak on 23.04.2023.
//

import UIKit

class MenuViewController: UIViewController {
    
    lazy var collectionView = MultiSectionExpandableList()
    
    let sectionData = [
        
        ListItem(title: "Grid", subItems: [
            ListItem(type: .gridLayout),
            ListItem(title: "Nested Groups", subItems: [
                ListItem(title: "Vertical Nested Groups", subItems: [
                    ListItem(type: .nestedGroup)
                ]),
                ListItem(title: "Horizontal Nested Groups", subItems: [
                    ListItem(type: .nestedGroup)
                ]),
            ]),
            ListItem(title: "Waterfall", subItems: [
                ListItem(type: .waterfall),
                ListItem(type: .horizontalWaterfall),
                ListItem(type: .stackWaterfall)
            ])
        ]),
        
        ListItem(title: "Collection View List", subItems: [
            ListItem(type: .simpleList),
            ListItem(type: .supplementary),
            ListItem(type: .multiSectionList)
        ])
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNavigationBar()
    }
    
    private func configureCollectionView(){
        view.addSubview(collectionView)
        collectionView.edgesToSuperview()
        collectionView.rootVC = self
        collectionView.performUpdates()
    }
    
    private func configureNavigationBar(){
        title = "Menu"
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemGray5
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}

extension MenuViewController: CollectionViewDataDelegte {
    func data() -> [AnyHashable] {
        return sectionData
    }
}
