//
//  DribbbleShot.swift
//  Hoopy
//
//  Created by Daniel Inoa on 8/13/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import Foundation
import Alamofire

struct DribbbleShot: CustomDebugStringConvertible {
    
    let title: String?
    let description: String?
    let author: String?
    let url: String?
    let avatarUrl: String?
    let animated: Bool
    
    private let imagesUrl: [String:Any]
    var highestResImageUrl: String? { return [hdImageUrl, imageUrl, teaserImageUrl].flatMap({ $0 }).first }
    var imageUrl: String? { return imagesUrl["normal"] as? String }
    var hdImageUrl: String? { return imagesUrl["hidpi"] as? String }
    var teaserImageUrl: String? { return imagesUrl["teaser"] as? String }
    
    // MARK: - Lifecycle
    
    init?(json: [String:Any?]) {
        guard let imagesUrl = json["images"] as? [String:AnyObject] else { return nil }
        self.imagesUrl = imagesUrl
        title = json["title"] as? String
        description = json["description"] as? String
        animated = (json["animated"] as? Int) == 1
        author = (json["user"] as? [String:AnyObject])?["name"] as? String
        avatarUrl = (json["user"] as? [String:AnyObject])?["avatar_url"] as? String
        url = json["html_url"] as? String
    }
    
    // MARK: - CustomDebugStringConvertible
    
    var debugDescription: String {
        return "\(title)"
    }
    
}

