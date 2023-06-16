//
//  ListModel.swift
//  AdvancedCompositionalLayout
//
//  Created by Ahmed Tarık Bozyak on 25.04.2023.
//

import Foundation
import UIKit

struct ListItem: Hashable {
    let id = UUID()
    let title: String
    let type: ListType?
    let subItems: [ListItem]
    
    init(type: ListType, subItems: [ListItem] = []) {
        self.type = type
        self.subItems = subItems
        self.title = type.title
    }
    
    init(title: String, subItems: [ListItem] = []) {
        self.type = nil
        self.subItems = subItems
        self.title = title
    }
}

enum ListType {
    case basicList
    case supplementary
    case multiSectionList
    case gridLayout
    case nestedGroup(type: NestedGroupType)
    case waterfall(type: WaterfallType)
    
    var viewController: UIViewController? {
        switch self {
        case .basicList: return BasicListViewController()
        case .supplementary: return SupplementaryViewController()
        case .multiSectionList: return MultiSectionViewController()
        case .gridLayout: return GridViewController()
        case .nestedGroup(let type): return NestedViewController(type: type)
        case .waterfall(let type): return WaterfallViewController(type: type)
        }
    }
    
    var title: String {
        switch self {
        case .basicList: return "Basic List Layout"
        case .supplementary: return "Supplementary View List"
        case .multiSectionList: return "Multi Section List"
        case .gridLayout: return "Basic Grid"
        case .waterfall(let type): return "\(type.rawValue) Waterfall"
        case .nestedGroup(let type):
            switch type {
            case .vertical(let layoutId): return "Vertical Nested Group \(layoutId)"
            case .horizontal(let layoutId): return "Horizontal Nested Group \(layoutId)"
            }
        }
    }
    
    var id: UUID {
        return UUID()
    }
}

extension ListType: Hashable {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .nestedGroup(let type):
            hasher.combine(type)
        case .waterfall(let type):
            hasher.combine(type)
        default : break
        }
    }
    
    static func == (lhs: ListType, rhs: ListType) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ListItem {
    static var defaultData: [Self] {
        return [
            ListItem(title: "Grid", subItems: [
                ListItem(type: .gridLayout),
                ListItem(title: "Nested Groups", subItems: [
                    ListItem(title: "Vertical Nested Groups", subItems: [
                        ListItem(type: .nestedGroup(type: .vertical(layoutId: 1)))
                    ]),
                    ListItem(title: "Horizontal Nested Groups", subItems: [
                        ListItem(type: .nestedGroup(type: .horizontal(layoutId: 1))),
                        ListItem(type: .nestedGroup(type: .horizontal(layoutId: 2))),
                        ListItem(type: .nestedGroup(type: .horizontal(layoutId: 3)))
                    ]),
                ]),
                ListItem(title: "Waterfall", subItems: [
                    ListItem(type: .waterfall(type: .vertical)),
                    ListItem(type: .waterfall(type: .horizontal)),
                    ListItem(type: .waterfall(type: .stack))
                ])
            ]),
            
            ListItem(title: "Collection View List", subItems: [
                ListItem(type: .basicList),
                ListItem(type: .supplementary),
                ListItem(type: .multiSectionList)
            ])
        ]
    }
}
