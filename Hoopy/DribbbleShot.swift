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
    
    /**
     Dictionary representation of receiver.
     */
    let dictionary: [String: Any]
    fileprivate let imagesUrl: [String: Any]
    
    // MARK: - Lifecycle
    
    init?(dictionary: [String: Any]) {
        guard let imagesUrl = dictionary["images"] as? [String: Any] else { return nil }
        self.dictionary = dictionary
        self.imagesUrl = imagesUrl
    }
    
}

extension DribbbleShot {
    
    var id: Int? {
        return dictionary["id"] as? Int
    }
    
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

extension DribbbleShot {
    
    static var favoriteShotsKey: String {
        return "favoriteShots"
    }
    
    /**
     Locally stores the specified shot in local collection of favorite shots.
     */
    static func favorite(shot: DribbbleShot) {
        let shots = remove(shot: shot) // remove shot if it already exists
        let data = NSKeyedArchiver.archivedData(withRootObject: shots.map({ $0.dictionary }) + [shot.dictionary])
        UserDefaults.standard.set(data, forKey: DribbbleShot.favoriteShotsKey)
    }
    
    /**
     Removes the specified from the local collection of favorite shots.
     */
    static func remove(shot: DribbbleShot) -> [DribbbleShot] {
        var shots = loadFavoriteShots()
        guard let shotID = shot.id else { return shots }
        let oldIndex = shots.index(where: {
            guard let id = $0.id else { return false }
            return id == shotID
        })
        if let index = oldIndex {
            shots.remove(at: index)
            let data = NSKeyedArchiver.archivedData(withRootObject: shots.map { $0.dictionary } )
            UserDefaults.standard.set(data, forKey: DribbbleShot.favoriteShotsKey)
        }
        return shots
    }
    
    /**
     Load local collection of favorite shots.
     */
    static func loadFavoriteShots() -> [DribbbleShot] {
        guard let data = UserDefaults.standard.data(forKey: DribbbleShot.favoriteShotsKey) else { return [] }
        guard let dictionaries = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[String: Any]] else { return [] }
        return dictionaries.flatMap({ DribbbleShot(dictionary: $0) })
    }
    
    var isFavorited: Bool {
        let shots = DribbbleShot.loadFavoriteShots()
        return shots.contains(where: {
            guard let retrievedID = $0.id, let id = self.id else { return false }
            return id == retrievedID
        })
    }
    
}
