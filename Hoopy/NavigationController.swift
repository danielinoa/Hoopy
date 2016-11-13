//
//  NavigationController.swift
//  Hoopy
//
//  Created by Daniel Inoa on 11/10/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    // MARK: - Lifecycle
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        navigationBar.tintColor = UIColor(hexString: "#FF0080")
        viewControllers = [rootViewController]
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("\(#function) has not been implemented") }

    // MARK: - View Controllers
    
    private var rootViewController: UIViewController {
        return ShotsViewController()
    }
    
}
