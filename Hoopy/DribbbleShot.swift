//
//  DribbbleShot.swift
//  Hoopy
//
//  Created by Daniel Inoa on 8/13/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import Foundation
import Alamofire

struct DribbbleShot {
    
    fileprivate let dictionary: [String: Any?]
    fileprivate let imagesUrl: [String: Any]
    
    // MARK: - Lifecycle
    
    init?(dictionary: [String:Any?]) {
        guard let imagesUrl = dictionary["images"] as? [String: Any] else { return nil }
        self.dictionary = dictionary
        self.imagesUrl = imagesUrl
    }
    
}

extension DribbbleShot {
    
    var title: String? {
        return dictionary["title"] as? String
    }
    
    var description: String? {
        return dictionary["description"] as? String
    }
    
    
    var author: String? {
        return (dictionary["user"] as? [String:AnyObject])?["name"] as? String
    }
    
    var url: String? {
        return dictionary["html_url"] as? String
    }
    
    var avatarUrl: String? {
        return (dictionary["user"] as? [String:AnyObject])?["avatar_url"] as? String
    }
    
    var animated: Bool {
        return (dictionary["animated"] as? Int) == 1
    }
    
    // MARK: - 
    
    var highestResImageUrl: String? { return [hdImageUrl, imageUrl, teaserImageUrl].flatMap({ $0 }).first }
    
    var imageUrl: String? {
        return imagesUrl["normal"] as? String
    }
    var hdImageUrl: String? {
        return imagesUrl["hidpi"] as? String
    }
    
    var teaserImageUrl: String? {
        return imagesUrl["teaser"] as? String
    }
    
}

extension DribbbleShot: CustomDebugStringConvertible {
    
    // MARK: - CustomDebugStringConvertible
    
    var debugDescription: String {
        return "\(title)"
    }
    
}
