//
//  ArrayExtensions.swift
//  Hoopy
//
//  Created by Daniel Inoa on 2/27/17.
//  Copyright © 2017 Daniel Inoa. All rights reserved.
//

import Foundation

extension Array {
    
    /**
     Returns the element after the specified index.
     */
    func element(after index: Index) -> Element? {
        let nextIndex = index + 1
        return nextIndex < count ? self[nextIndex] : nil
    }
    
    /**
     Returns the element before the specified index.
     */
    func element(before index: Index) -> Element? {
        let nextIndex = index - 1
        return nextIndex >= 0 ? self[nextIndex] : nil
    }
    
}
