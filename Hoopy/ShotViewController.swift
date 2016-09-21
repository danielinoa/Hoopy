//
//  ShotViewController.swift
//  Hoopy
//
//  Created by Daniel Inoa on 9/17/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit
import Alamofire
import FLAnimatedImage
import TUSafariActivity
import FTIndicator

protocol ShotViewControllerDelegate: class {
    func shotViewController(shotViewController: ShotViewController, favoriteToggledShot: DribbbleShot)
}

final class ShotViewController: UIViewController {

    /*
     KNOWN ISSUE:
     In iOS 9, the VisualEffectView's blur would animate along with the presentation of the view controller.
     As of iOS 10, cross-disolve segue transitions look glitchy when the destination view controller
     (presented as a modal over full screen) has a VisualEffectView as background.
     WORKAROUND:
     In order to properly animate the VisualEffectView's blur, the effectView alpha value is zeroed
     when the view loads. Once the view has appeared the alpha value is brought back to 1 with an animation.
     To prevent a transition delay, the segue is set to not animate (through IB).
     */
    
    @IBOutlet fileprivate weak var visualEffectView: UIVisualEffectView!
    @IBOutlet fileprivate weak var imageWrapperView: UIView!
    @IBOutlet fileprivate weak var imageView: FLAnimatedImageView!
    @IBOutlet fileprivate weak var progressView: UIProgressView!
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var authorLabel: UILabel!
    @IBOutlet fileprivate weak var authorImageView: UIImageView!
    @IBOutlet fileprivate weak var actionButton: UIButton!
    @IBOutlet fileprivate weak var favoriteButton: UIButton!
    
    var dribbbleShot: DribbbleShot!
    var placeholderImage: UIImage?
    fileprivate var image: UIImage?
    
    weak var delegate: ShotViewControllerDelegate?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(dribbbleShot != nil, "Expects `dribbbleShot` to be set when view loads")
        imageWrapperView.addGestureRecognizer(tapGesture)
        imageView.addGestureRecognizer(doubleTapGesture)
        scrollView.delegate = self
        configureFavoriteButton()
        configureShot()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.subviews.forEach { $0.alpha = 0 }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.2) {
            self.view.subviews.forEach { $0.alpha = 1 }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        authorImageView.layer.cornerRadius = min(authorImageView.bounds.width, authorImageView.bounds.height)/2
    }
    
    // MARK: -
    
    fileprivate func configureShot() {
        titleLabel.text = dribbbleShot?.title ?? ""
        authorLabel.text = dribbbleShot?.author ?? ""
        imageView.image = placeholderImage
        
        // Retrieves author image
        if let avatarUrlString = dribbbleShot?.avatarUrl, let avatarUrl = URL(string: avatarUrlString) {
            authorImageView.image = nil
            authorImageView.af_setImage(withURL: avatarUrl)
        }
        
        // Retrieves shot
        if let dribbbleShot = dribbbleShot, let hdImageUrlPath = dribbbleShot.highestResImageUrl {
            let request = Alamofire.request(hdImageUrlPath)
            request.responseJSON { response in
                DispatchQueue.main.async {
                    if let data = response.data {
                        UIView.animate(withDuration: 0.5) { self.progressView.alpha = 0 }
                        if dribbbleShot.animated {
                            self.imageView.animatedImage = FLAnimatedImage(gifData: data)
                        } else {
                            self.imageView.image = UIImage(data: data)
                        }
                    }
                }
            }
            request.downloadProgress(closure: { progress in
                let fractionCompleted = Float(progress.fractionCompleted)
                self.progressView.setProgress(fractionCompleted, animated: true)
            })
        }
    
    }
    
    fileprivate func configureFavoriteButton() {
        let imageName = "heart-\(dribbbleShot.isFavorited ? "filled" : "empty")"
        favoriteButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    // MARK: - Gestures
    
    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        gesture.delegate = self
        return gesture
    }()
    
    fileprivate lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        gesture.numberOfTapsRequired = 2
        gesture.delegate = self
        return gesture
    }()
    
    @objc fileprivate func tap(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.subviews.forEach { $0.alpha = 0 }
        }) { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func doubleTap(_ sender: AnyObject) {
        guard let gestureRecognizer = sender as? UITapGestureRecognizer else { return }
        let locationOfTouch = gestureRecognizer.location(ofTouch: 0, in: imageWrapperView)
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        } else {
            scrollView.zoom(to: CGRect(origin: locationOfTouch, size: .zero), animated: true)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction fileprivate func actionButtonTapped() {
        if let dribbbleShot = dribbbleShot, let urlPath = dribbbleShot.url, let url = NSURL(string: urlPath), let image = imageView.image {
            let safariActivity = TUSafariActivity()
            let activityViewController = UIActivityViewController(activityItems: [image, url], applicationActivities: [safariActivity])
            activityViewController.excludedActivityTypes = [.assignToContact, .addToReadingList, .print]
            activityViewController.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                guard let activityType = activityType else { return }
                if activityType == .saveToCameraRoll {
                    FTIndicator.showToastMessage("Image Saved!")
                } else if activityType == .copyToPasteboard {
                    FTIndicator.showToastMessage("Copied!")
                }
            }
            present(activityViewController, animated: true) {}
        }
    }
    
    // change func name
    @IBAction func favoriteAction(_ sender: AnyObject) {
        if dribbbleShot.isFavorited {
            DribbbleShot.remove(shot: dribbbleShot)
        } else {
            DribbbleShot.favorite(shot: dribbbleShot)
        }
        configureFavoriteButton()
        delegate?.shotViewController(shotViewController: self, favoriteToggledShot: dribbbleShot)
    }
    
}

extension ShotViewController: UIScrollViewDelegate {
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.zoomScale = scrollView.zoomScale < 1 ? 1 : scrollView.zoomScale
        UIView.animate(withDuration: 0.3) {
            self.titleLabel.alpha  = scrollView.zoomScale < 1.5 ? 1 : 0
            self.authorLabel.alpha = scrollView.zoomScale < 1.5 ? 1 : 0
            self.authorImageView.alpha = scrollView.zoomScale < 1.5 ? 1 : 0
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageWrapperView
    }
    
}

extension ShotViewController: UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (gestureRecognizer == tapGesture && touch.view == imageWrapperView) || (gestureRecognizer == doubleTapGesture && touch.view == imageView)
    }
    
}
