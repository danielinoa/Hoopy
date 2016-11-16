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

protocol ShotViewControllerDelegate: class {
    func shotViewController(shotViewController: ShotViewController, favoriteToggledShot: DribbbleShot)
}

final class ShotViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet private weak var imageWrapperView: UIView!
    @IBOutlet private(set) weak var imageView: FLAnimatedImageView!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var authorImageView: UIImageView!
    
    let dribbbleShot: DribbbleShot
    let placeholderImage: UIImage?
    private var image: UIImage?
    
    weak var delegate: ShotViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    init(shot: DribbbleShot, placeholderImage: UIImage? = nil) {
        self.dribbbleShot = shot
        self.placeholderImage = placeholderImage
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) { fatalError("\(#function) has not been implemented") }
    required init?(coder aDecoder: NSCoder) { fatalError("\(#function) has not been implemented") }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageWrapperView.addGestureRecognizer(tapGesture)
        imageView.addGestureRecognizer(doubleTapGesture)
        scrollView.delegate = self
        configureShot()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        authorImageView.layer.cornerRadius = min(authorImageView.bounds.width, authorImageView.bounds.height)/2
    }
    
    // MARK: -
    
    private func configureShot() {
        titleLabel.text = dribbbleShot.title
        authorLabel.text = dribbbleShot.author
        imageView.image = placeholderImage
        
        // Retrieves author image
        if let avatarUrlString = dribbbleShot.avatarUrl, let avatarUrl = URL(string: avatarUrlString) {
            authorImageView.image = nil
            authorImageView.af_setImage(withURL: avatarUrl)
        }
        
        // Retrieves shot
        if let hdImageUrlPath = dribbbleShot.highestResImageUrl {
            let request = Alamofire.request(hdImageUrlPath)
            request.responseJSON { response in
                DispatchQueue.main.async {
                    if let data = response.data {
                        UIView.animate(withDuration: 0.5) { self.progressView.alpha = 0 }
                        if self.dribbbleShot.animated {
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
    
    // MARK: - Gestures
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        gesture.delegate = self
        return gesture
    }()
    
    private lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        gesture.numberOfTapsRequired = 2
        gesture.delegate = self
        return gesture
    }()
    
    @objc private func tap(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.subviews.forEach { $0.alpha = 0 }
        }) { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func doubleTap(_ sender: AnyObject) {
        guard let gestureRecognizer = sender as? UITapGestureRecognizer else { return }
        let locationOfTouch = gestureRecognizer.location(ofTouch: 0, in: imageWrapperView)
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        } else {
            scrollView.zoom(to: CGRect(origin: locationOfTouch, size: .zero), animated: true)
        }
    }
    
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
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (gestureRecognizer == tapGesture && touch.view == imageWrapperView) || (gestureRecognizer == doubleTapGesture && touch.view == imageView)
    }
    
}
