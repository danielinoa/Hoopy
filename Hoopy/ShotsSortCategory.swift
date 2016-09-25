//
//  ShotsSortCategory.swift
//  Hoopy
//
//  Created by Daniel Inoa on 9/24/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import Foundation

enum ShotsSortCategory: Int {
    
    case recent = 0
    case mostViewed
    
    var all: [ShotsSortCategory] {
        return [.recent, .mostViewed]
    }
    
    var dataSourceSortValue: String {
        switch self {
            case .recent: return "recent"
            case .mostViewed: return "views"
        }
    }
    
    static var defaultCategoryKey: String {
        return "defaultShotsSortCategory"
    }
    
    static var defaultCategory: ShotsSortCategory {
        get {
            let defaultRawValue = UserDefaults.standard.integer(forKey: defaultCategoryKey)
            if let category = ShotsSortCategory(rawValue: defaultRawValue) {
                return category
            } else {
                return .recent
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: defaultCategoryKey)
        }
    }
    
}
