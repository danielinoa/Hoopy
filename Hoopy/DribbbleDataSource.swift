//
//  DribbbleDataSource.swift
//  Hoopy
//
//  Created by Daniel Inoa on 8/27/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import Foundation
import Alamofire

final class DribbbleDataSource {
    
    private let dribbbleAccessToken = "[DRIBBBLE_ACCESS_TOKEN]"
    
    // TODO: retrieve next page number based on LINK
    private(set) var page = 1
    private(set) var shots: [DribbbleShot] = []
    let category: Category
    
    init(category: Category) {
        self.category = category
    }
    
    func loadCurrentPageOfShots(completion: ((_ shots: [DribbbleShot]?) -> Void)? = nil) {
        let parameters: Parameters = [
            "access_token": dribbbleAccessToken,
            "page":"\(page)",
            "list":"\(category.rawValue)",
            "sort":"\(ShotsSortCategory.defaultCategory)"
        ]
        let request = Alamofire.request("https://api.dribbble.com/v1/shots", parameters: parameters)
        request.responseJSON { response in
            if let responseData = response.data,
                let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments),
                let dictionariesArray = json as? [[String: Any]] {
                let newShots: [DribbbleShot] = dictionariesArray.flatMap({ DribbbleShot(dictionary: $0) })
                let shotsOrderedSet = NSOrderedSet(array: self.shots + newShots)
                self.shots = shotsOrderedSet.array as! [DribbbleShot]
                completion?(newShots)
            } else {
                completion?(nil)
            }
        }
    }
    
    func loadNextPageOfShots(completion: @escaping ((_ shots: [DribbbleShot]?) -> Void)) {
        page += 1
        loadCurrentPageOfShots(completion: completion)
    }
    
    /**
     Resets the page number to 1 and clear the shots array
     */
    func reset() {
        page = 1
        shots = []
    }
    
    enum Category: String {
        case popular = "popular"
        case animated = "animated"
        case debuts = "debuts"
        
        static var all: [Category] {
            return [popular, animated, debuts]
        }
    }
    
}
