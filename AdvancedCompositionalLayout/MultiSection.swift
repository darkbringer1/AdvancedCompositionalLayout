//
//  MultiSection.swift
//  AdvancedCompositionalLayout
//
//  Created by Ahmed Tarık Bozyak on 16.06.2023.
//

import Foundation
import UIKit

typealias MultiSectionSnapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
typealias MultiSectionDataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>

class MultiSection: UICollectionView {
    
    weak var rootVC: UIViewController!
    
    var datasource: MultiSectionDataSource!
    
    var sectionList: [Section] {
        let delegate = rootVC as? CollectionViewDataDelegte
        return delegate?.data() as? [Section] ?? []
    }
    
    override init(frame: CGRect = .zero, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit(){
        setCollectionViewLayout(UICollectionViewCompositionalLayout(sectionProvider: layout), animated: false)
        configureDataSource()
    }
    
    func configureDataSource(){
        
        let gridCellRegistration = UICollectionView.CellRegistration<GridCell, Int> { (cell, _, item) in
            cell.configure(with: item)
        }
        
        let waterfallCellRegistration = UICollectionView.CellRegistration<WaterfallCell, Int> { (cell, _, item) in
            cell.configure(with: item, bgColor: .systemBlue.withAlphaComponent(0.8), cornerRadius: 10)
        }
        
        datasource = UICollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: self) { [unowned self]
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            let section = self.sectionList[indexPath.section]
            switch section.cellType {
            case is GridCell.Type:
                guard let data = section.data as? [Int] else {return nil}
                return collectionView.dequeueConfiguredReusableCell(using: gridCellRegistration, for: indexPath, item: data[indexPath.row])
            case is WaterfallCell.Type:
                guard let data = section.data as? [Int] else {return nil}
                return collectionView.dequeueConfiguredReusableCell(using: waterfallCellRegistration, for: indexPath, item: data[indexPath.row])
            default : return nil
            }
            
            
        }
    }
    
    // MARK: Layout
    private func layout(for sectionIndex: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        return sectionList[sectionIndex].layout(environment)
    }
    
    // MARK: PerformUpdates
    func performUpdates(){
        var snapshot = MultiSectionSnapshot()
        sectionList.forEach({
            snapshot.appendSections([$0])
            snapshot.appendItems($0.data)
        })
        datasource.apply(snapshot,animatingDifferences: true)
    }
    
}

