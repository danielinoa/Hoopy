//
//  NavigationController.swift
//  Hoopy
//
//  Created by Daniel Inoa on 11/10/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

final class NavigationController: UINavigationController {

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
    
    private let rootViewController = ShotsViewController()
    
    // MARK: - Shortcut Items
    
    func handle(shortcutItem: UIApplicationShortcutItem, completion: ((Bool) -> Void)? = nil) {
        guard let type = ShortcutItemType(rawValue: shortcutItem.type) else {
            completion?(false)
            return
        }
        
        popToRootViewController(animated: false)
        dismiss(animated: false, completion: nil)
        
        switch type {
        case .favorites:
            let favoritesViewController = FavoritesViewController()
            show(favoritesViewController, sender: self)
            completion?(true)
        case .settings:
            // FIXME: view controller is not being presented unless there is a delay.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let settingsViewController = SettingsViewController()
                settingsViewController.modalPresentationStyle = .overCurrentContext
                self.present(settingsViewController, animated: false) {
                    completion?(true)
                }
            }
        }
    }
    
}
