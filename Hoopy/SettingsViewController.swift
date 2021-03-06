//
//  SettingsViewController.swift
//  Hoopy
//
//  Created by Daniel Inoa on 9/24/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

final class SettingsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet private var bottomToBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var topToBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var sortShotsLabel: UILabel!
    @IBOutlet weak private var layoutShotsLabel: UILabel!
    @IBOutlet weak private var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak private var layoutSegmentedControl: UISegmentedControl!
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
    
    private var shotsLayoutManager = ShotsLayoutManager.shared
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        view.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
        
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
    
    private func setSettingsViewVisible(flag: Bool = true, completion: (() -> Void)? = nil) {
        
        // First disable all constraints.
        topToBottomConstraint.isActive = false
        bottomToBottomConstraint.isActive = false
        
        // Then enable the corresponding constraint that will either show or hide the actionsheet.
        topToBottomConstraint.isActive = !flag
        bottomToBottomConstraint.isActive = flag
        
        view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
            self.view.backgroundColor = flag ? UIColor.black.withAlphaComponent(0.35) : .clear
        }) { _ in
            completion?()
        }
    }
    
    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        setSettingsViewVisible(flag: false) { 
            self.dismiss(animated: true, completion: {})
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (gestureRecognizer == tapGestureRecognizer && touch.view == view)
    }
    
    // MARK: -
    
    @IBAction private func sortSegmentedControlChangedValue(_ segmentedControl: UISegmentedControl) {
        guard segmentedControl == sortSegmentedControl else { return }
        if let category = ShotsSortCategory(rawValue: sortSegmentedControl.selectedSegmentIndex) {
            ShotsSortCategory.defaultCategory = category
        }
    }
    
    @IBAction private func layoutSegmentedControlChangedValue(_ segmentedControl: UISegmentedControl) {
        guard segmentedControl == layoutSegmentedControl else { return }
        shotsLayoutManager.shotsInRow = layoutSegmentedControl.selectedSegmentIndex + 2
    }
    
}
