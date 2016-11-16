//
//  ShotsCarouselViewController.swift
//  Hoopy
//
//  Created by Daniel Inoa on 11/13/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit
import Photos
import FTIndicator
import TUSafariActivity

protocol ShotsCarouselViewControllerDelegate: class {
    func favoriteToggled(shot: DribbbleShot, in: ShotsCarouselViewController)
}

protocol ShotsCarouselViewControllerDataSource: class {
    func shotBefore(shot: DribbbleShot, in: ShotsCarouselViewController) -> DribbbleShot?
    func shotAfter(shot: DribbbleShot, in: ShotsCarouselViewController) -> DribbbleShot?
}

final class ShotsCarouselViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    /*
     KNOWN ISSUE:
     In iOS 9, the VisualEffectView's blur would animate along with the presentation of the view controller.
     As of iOS 10, cross-disolve segue transitions look glitchy when the destination view controller
     (presented as a modal over full screen) has a VisualEffectView as background.
     WORKAROUND:
     In order to properly animate the VisualEffectView's blur, the effectView alpha value is zeroed
     when the view loads. Once the view has appeared the alpha value is brought back to 1 with an animation.
     To prevent a transition delay, the presentation must be set to not animate.
     */
    
    weak var delegate: ShotsCarouselViewControllerDelegate?
    weak var dataSource: ShotsCarouselViewControllerDataSource?
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var favoriteButton: ExtendedHitButton!
    
    // MARK: - Lifecycle
    
    init(shot: DribbbleShot) {
        super.init(nibName: nil, bundle: nil)
        
        let shotViewController = ShotViewController(shot: shot)
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([shotViewController], direction: .forward, animated: false, completion: nil)
        
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) { fatalError() }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add page view controller as child view controller
        addChildViewController(pageViewController)
        visualEffectView.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
        view.backgroundColor = .clear
        view.subviews.forEach { $0.alpha = 0 }
        configureFavoriteButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.2) {
            self.view.subviews.forEach { $0.alpha = 1 }
        }
    }
    
    // MARK: - 
    
    private func configureFavoriteButton() {
        if let shotViewController = (pageViewController.viewControllers?.first as? ShotViewController) {
            let imageName = "heart-\(shotViewController.dribbbleShot.isFavorited ? "filled" : "empty")"
            favoriteButton.setImage(UIImage(named: imageName), for: .normal)
        }
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let shotViewController = viewController as? ShotViewController,
            let previousShot = dataSource?.shotBefore(shot: shotViewController.dribbbleShot, in: self) {
            let shotViewController = ShotViewController(shot: previousShot)
            return shotViewController
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let shotViewController = viewController as? ShotViewController,
            let nextShot = dataSource?.shotAfter(shot: shotViewController.dribbbleShot, in: self) {
            let shotViewController = ShotViewController(shot: nextShot)
            return shotViewController
        }
        return nil
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            configureFavoriteButton()
        }
    }
    
    // MARK: - IBActions
    
    @IBAction private func actionButtonTapped() {
        if let shotViewController = (pageViewController.viewControllers?.first as? ShotViewController),
            let urlPath = shotViewController.dribbbleShot.url,
            let url = NSURL(string: urlPath),
            let image = shotViewController.imageView.image {
            let safariActivity = TUSafariActivity()
            let activityViewController = UIActivityViewController(activityItems: [image, url], applicationActivities: [safariActivity])
            activityViewController.excludedActivityTypes = [.assignToContact, .addToReadingList, .print]
            activityViewController.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                guard let activityType = activityType else { return }
                if activityType == .saveToCameraRoll && PHPhotoLibrary.authorizationStatus() == .authorized {
                    FTIndicator.showToastMessage("Image Saved!")
                } else if activityType == .copyToPasteboard {
                    FTIndicator.showToastMessage("Copied!")
                }
            }
            present(activityViewController, animated: true) {}
        }
    }
    
    @IBAction private func favoriteAction(_ sender: AnyObject) {
        if let shotViewController = (pageViewController.viewControllers?.first as? ShotViewController) {
            let dribbbleShot = shotViewController.dribbbleShot
            if dribbbleShot.isFavorited {
                let _ = DribbbleShot.unfavorite(shot: dribbbleShot)
            } else {
                DribbbleShot.favorite(shot: dribbbleShot)
            }
            delegate?.favoriteToggled(shot: dribbbleShot, in: self)
        }
        configureFavoriteButton()
    }
    
    // MARK: - Status Bar Style
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
