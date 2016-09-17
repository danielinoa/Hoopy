//
//  FontExtensions.swift
//  Hoopy
//
//  Created by Daniel Inoa on 8/28/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

extension UIFont {
    
    var smallCaps: UIFont {
        let settings = [[UIFontFeatureTypeIdentifierKey: kLowerCaseType, UIFontFeatureSelectorIdentifierKey: kLowerCaseSmallCapsSelector]]
        let attributes: [String: Any] = [UIFontDescriptorFeatureSettingsAttribute: settings, UIFontDescriptorNameAttribute: fontName]
        return UIFont(descriptor: UIFontDescriptor(fontAttributes: attributes), size: pointSize)
    }
    
}
