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
    
    fileprivate let dribbbleAccessToken = "[DRIBBBLE_ACCESS_TOKEN]"
    
    // TODO: retrieve next page number based on LINK
    fileprivate(set) var page = 1
    fileprivate(set) var shots: [DribbbleShot] = []
    let category: Category
    
    init(category: Category) {
        self.category = category
    }
    
    // TODO: add error parameter in completion block
    func loadCurrentPageOfShots(completion: ((_ shots: [DribbbleShot]?) -> Void)? = nil) {
        let parameters: Parameters = [
            "access_token": dribbbleAccessToken,
            "page":"\(page)",
            "list":"\(category.rawValue)",
            "sort":"\(ShotsSortCategory.defaultCategory)"
        ]
        let request = Alamofire.request("https://api.dribbble.com/v1/shots", parameters: parameters)
        request.responseJSON { response in
            do {
                let json = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments)
                if let dictionariesArray = json as? [[String: Any]] {
                    let shots: [DribbbleShot] = dictionariesArray.flatMap({ DribbbleShot(dictionary: $0) })
                    self.shots += shots
                    completion?(shots)
                } else {
                    completion?(nil)
                }
            } catch {
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
    
}

extension DribbbleDataSource {
    
    enum Category: String {
        case popular = "popular"
        case animated = "animated"
        case debuts = "debuts"
        
        static var all: [Category] {
            return [popular, animated, debuts]
        }
    }
    
}
