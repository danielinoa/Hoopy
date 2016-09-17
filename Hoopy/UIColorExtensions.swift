//
//  UIColorExtensions.swift
//  Hoopy
//
//  Created by Daniel Inoa on 8/27/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init (hexString: String) {
        var cleanHexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if cleanHexString.hasPrefix("#") {
            cleanHexString = cleanHexString.substring(from: cleanHexString.index(cleanHexString.startIndex, offsetBy: String.IndexDistance(1)) )
        }
        guard cleanHexString.characters.count == 6 else {
            self.init()
            return
        }
        var rgbValue = UInt32()
        let scanner = Scanner(string: cleanHexString)
        scanner.scanHexInt32(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16)/255.0,
            green: CGFloat((rgbValue & 0xFF00) >> 8)/255.0,
            blue: CGFloat(rgbValue & 0xFF)/255.0,
            alpha: 1.0)
    }
    
}
