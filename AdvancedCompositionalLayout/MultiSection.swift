//
//  MultiSection.swift
//  AdvancedCompositionalLayout
//
//  Created by Ahmed Tarık Bozyak on 16.06.2023.
//

import Foundation
import UIKit
import Combine

typealias MultiSectionSnapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
typealias MultiSectionDataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>

protocol PagerDelegate: AnyObject {
    func didValueChanged(indexPath: IndexPath, scrollPosition: UICollectionView.ScrollPosition)
}

protocol CollectionViewUpdate: AnyObject {
    func updateLayout()
}

class MultiSection: UICollectionView {
    
    weak var rootVC: UIViewController!
    
    var datasource: MultiSectionDataSource!
    
    var headerRegistration: UICollectionView.SupplementaryRegistration<HeaderView>!
    
    var tabHeaderRegistration: UICollectionView.SupplementaryRegistration<TabHeaderView>!
    
    var footerRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!
    
    var pagingFooterRegistration: UICollectionView.SupplementaryRegistration<PagerFooterView>!
    
    var badgeRegistration: UICollectionView.SupplementaryRegistration<BadgeView>!
    
    //For testing
    let data = [
        Menu(title: "Todo"),
        Menu(title: "In Progress"),
        Menu(title: "Waiting Info"),
        Menu(title: "Waiting Test"),
        Menu(title: "Done"),
    ]
    
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
        backgroundColor = .systemGray6
        configureDataSource()
        configureSupplementaryViews()
    }
    
    func configureDataSource(){
        
        let personCellRegistration = UICollectionView.CellRegistration<PersonCell, Person> { (cell, indexPath, item) in
            cell.configure(with: item)
        }
        
        let nestedCellRegistration = UICollectionView.CellRegistration<NestedCell, Int> { (cell, indexPath, item) in
            cell.configure(with: item)
            cell.backgroundColor = UIColor(named: "section\(indexPath.section)CellColor")
        }
        
        let gridCellRegistration = UICollectionView.CellRegistration<GridCell, Int> { (cell, indexPath, item) in
            cell.configure(with: item)
            cell.backgroundColor = UIColor(named: "section\(indexPath.section)CellColor")
        }
        
        let waterfallCellRegistration = UICollectionView.CellRegistration<WaterfallCell, Int> { (cell, indexPath, item) in
            cell.configure(with: item, bgColor: .systemBlue.withAlphaComponent(0.8))
            cell.backgroundColor = UIColor(named: "section\(indexPath.section)CellColor")
        }
        
        let taskCellRegistration = UICollectionView.CellRegistration<TaskCell, Task> { (cell, indexPath, item) in
            cell.configure(with: item)
            cell.backgroundColor = UIColor(named: "section\(indexPath.section)CellColor")
        }
        
        let taskStatisticsCellRegistration = UICollectionView.CellRegistration<TaskStatisticsCell, TaskStatistics> { (cell, indexPath, item) in
            cell.configure(with: item)
            cell.backgroundColor = UIColor(named: "section\(indexPath.section)CellColor")
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
                
            case is NestedCell.Type:
                guard let data = section.data as? [Int] else {return nil}
                return collectionView.dequeueConfiguredReusableCell(using: nestedCellRegistration, for: indexPath, item: data[indexPath.row])
                
            case is PersonCell.Type:
                guard let data = section.data as? [Person] else {return nil}
                return collectionView.dequeueConfiguredReusableCell(using: personCellRegistration, for: indexPath, item: data[indexPath.row])
                
            case is TaskCell.Type:
                guard let data = section.data as? [Task] else {return nil}
                return collectionView.dequeueConfiguredReusableCell(using: taskCellRegistration, for: indexPath, item: data[indexPath.row])
            
            case is TaskStatisticsCell.Type:
                guard let data = section.data as? [TaskStatistics] else {return nil}
                return collectionView.dequeueConfiguredReusableCell(using: taskStatisticsCellRegistration, for: indexPath, item: data[indexPath.row])
                
            default : return nil
            }
        }
    }
    
    private func configureSupplementaryViews(){
        
        headerRegistration = .init(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self]
            (header, elementKind, indexPath) in
            let sectionTitle = self.datasource.sectionIdentifier(for: indexPath.section)?.title ?? ""
            header.configure(with: sectionTitle)
        }
        
        tabHeaderRegistration = .init(elementKind: UICollectionView.elementKindSectionHeader, handler: { [unowned self] header, elementKind, indexPath in
            if let pageListener = self.datasource.sectionIdentifier(for: indexPath.section)?.pageListener {
                header.subscribeTo(subject: pageListener, for: indexPath.section)
            }
            header.configure(menuData: self.data, indexPath: indexPath, delegate: self)
            
        })
        
        footerRegistration = .init(elementKind: UICollectionView.elementKindSectionFooter) {
            (footer, elementKind, indexPath) in
            var configuration = footer.defaultContentConfiguration()
            configuration.directionalLayoutMargins.bottom = 24
            let dataCount = self.datasource.sectionIdentifier(for: indexPath.section)?.data.count ?? 0
            configuration.text = "Item count: " + "\(dataCount)"
            footer.contentConfiguration = configuration
        }
        
        pagingFooterRegistration = .init(elementKind: UICollectionView.elementKindSectionFooter) { [weak self]
            (footer, elementKind, indexPath) in
            if let pageListener = self?.datasource.sectionIdentifier(for: indexPath.section)?.pageListener {
                footer.subscribeTo(subject: pageListener, for: indexPath.section)
            }
            footer.configure(numberOfPages: self?.sectionList[indexPath.section].data.count ?? 0, indexPath: indexPath, delegate: self)
        }
        
        badgeRegistration = .init(elementKind: "badgeElementKind", handler: { [unowned self] supplementaryView, elementKind, indexPath in
            let personData = datasource.sectionIdentifier(for: indexPath.section)?.data as? [Person] ?? []
            supplementaryView.configure(status: personData[indexPath.row].status)
        })
        
        
        datasource.supplementaryViewProvider = supplementaryView
        
    }
    
    
    private func supplementaryView(in collection: UICollectionView, elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
        if elementKind == UICollectionView.elementKindSectionHeader {
            switch sectionList[indexPath.section].headerType {
            case is TabHeaderView.Type:
                return self.dequeueConfiguredReusableSupplementary(using: tabHeaderRegistration, for: indexPath)
            default:
                return self.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            }
            
        }
        
        else if elementKind == UICollectionView.elementKindSectionFooter{
            switch sectionList[indexPath.section].footerType {
            case is PagerFooterView.Type:
                return self.dequeueConfiguredReusableSupplementary(using: pagingFooterRegistration, for: indexPath)
            default:
                return self.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
            }
        }
        
        else {
            return self.dequeueConfiguredReusableSupplementary(using: badgeRegistration, for: indexPath)
        }
    }
    
    // MARK: Layout
    private func layout(for sectionIndex: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let section = datasource.sectionIdentifier(for: sectionIndex)
        return section?.layout(sectionIndex ,environment, section?.data.count ?? 1, section?.pageListener)
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

extension MultiSection: PagerDelegate {
    func didValueChanged(indexPath: IndexPath, scrollPosition: UICollectionView.ScrollPosition) {
        self.scrollToItem(at: indexPath, at: scrollPosition, animated: true)
    }
}

extension MultiSection: CollectionViewUpdate {
    func updateLayout() {
        collectionViewLayout.invalidateLayout()
    }
}
