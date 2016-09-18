//
//  ExtendedHitButton.swift
//  Hoopy
//
//  Created by Daniel Inoa on 9/17/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

@IBDesignable class ExtendedHitButton: UIButton {
    
    @IBInspectable var hitTestTopOffset: CGFloat = 0
    @IBInspectable var hitTestLeftOffset: CGFloat = 0
    @IBInspectable var hitTestBottomOffset: CGFloat = 0
    @IBInspectable var hitTestRightOffset: CGFloat = 0
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let  hitTestEdgeInsets = UIEdgeInsets(top: -hitTestTopOffset,
                                              left: -hitTestLeftOffset,
                                              bottom: -hitTestBottomOffset,
                                              right: -hitTestRightOffset)
        let hitFrame = UIEdgeInsetsInsetRect(bounds, hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
}
