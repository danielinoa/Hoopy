//
//  EmptyShotsView.swift
//  Hoopy
//
//  Created by Daniel Inoa on 9/20/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

class EmptyShotsView: UIView {

    class func instanceFromNib(withOwner owner: Any? = nil) -> EmptyShotsView {
        let nib = UINib.init(nibName: "EmptyShotsView", bundle: nil)
        return nib.instantiate(withOwner: owner, options: nil).first as! EmptyShotsView
    }

}
