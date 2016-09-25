//
//  SettingsViewController.swift
//  Hoopy
//
//  Created by Daniel Inoa on 9/24/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

final class SettingsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet fileprivate var bottomToBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var topToBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet weak fileprivate var sortShotsLabel: UILabel!
    @IBOutlet weak fileprivate var layoutShotsLabel: UILabel!
    @IBOutlet weak fileprivate var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak fileprivate var layoutSegmentedControl: UISegmentedControl!
    
    fileprivate var shotsLayoutManager = ShotsLayoutManager.shared
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        view.addGestureRecognizer(tapGesture)
        
        layoutSegmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12).smallCaps], for: .normal)
        sortSegmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12).smallCaps], for: .normal)
        sortShotsLabel.font = UIFont.systemFont(ofSize: 16).smallCaps
        layoutShotsLabel.font = UIFont.systemFont(ofSize: 16).smallCaps
        
        layoutSegmentedControl.selectedSegmentIndex = shotsLayoutManager.shotsInRow - 2
        sortSegmentedControl.selectedSegmentIndex = ShotsSortCategory.defaultCategory.rawValue
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setSettingsViewVisible()
    }
    
    // MARK: -
    
    fileprivate func setSettingsViewVisible(flag: Bool = true, completion: (() -> Void)? = nil) {
        /*
         Long `if` statement to avoid breaking constraints.
         Constraints to-be-removed should be removed (marked as false) first before adding new ones.
         */
        if flag {
            topToBottomConstraint.isActive = false
            bottomToBottomConstraint.isActive = true
        } else {
            bottomToBottomConstraint.isActive = false
            topToBottomConstraint.isActive = true
        }
        
        view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
            self.view.backgroundColor = flag ? UIColor.black.withAlphaComponent(0.35) : .clear
        }) { _ in
            completion?()
        }
    }
    
    @IBAction fileprivate func tapped(_ sender: UITapGestureRecognizer) {
        setSettingsViewVisible(flag: false) { 
            self.dismiss(animated: true, completion: {})
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (gestureRecognizer == tapGesture && touch.view == view)
    }
    
    // MARK: -
    
    @IBAction fileprivate func sortSegmentedControlChangedValue(_ segmentedControl: UISegmentedControl) {
        guard segmentedControl == sortSegmentedControl else { return }
        if let category = ShotsSortCategory(rawValue: sortSegmentedControl.selectedSegmentIndex) {
            ShotsSortCategory.defaultCategory = category
        }
    }
    
    @IBAction fileprivate func layoutSegmentedControlChangedValue(_ segmentedControl: UISegmentedControl) {
        guard segmentedControl == layoutSegmentedControl else { return }
        shotsLayoutManager.shotsInRow = layoutSegmentedControl.selectedSegmentIndex + 2
    }
    
}
