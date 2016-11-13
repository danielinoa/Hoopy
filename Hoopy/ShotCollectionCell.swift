//
//  ShotCollectionCell.swift
//  Hoopy
//
//  Created by Daniel Inoa on 8/15/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import Foundation
import AlamofireImage

final class ShotCollectionCell: UICollectionViewCell {
    
    static let reuseIdentifier = "shotCollectionCell"
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    fileprivate func configure() {
        backgroundColor = .black
        clipsToBounds = true
        addSubview(imageView)
        addSubview(gifLabel)
    }
    
    // MARK: - Configure
    
    func configure(with shot: DribbbleShot) {
        gifLabel.isHidden = !shot.animated
        if let imageUrlString = shot.imageUrl, let imageUrl = URL(string: imageUrlString) {
            imageView.image = nil
            imageView.af_setImage(withURL: imageUrl, imageTransition: .crossDissolve(0.2))
        }
    }
    
    // MARK: - Subviews
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.animationRepeatCount = 0
        imageView.animationDuration = Double.infinity
        imageView.startAnimating()
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    let gifLabel: UILabel = {
        let label = UILabel()
        label.text = "gif"
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.backgroundColor = .black
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 10).smallCaps
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        let gifLabelSize = gifLabel.intrinsicContentSize
        gifLabel.frame = CGRect(origin: CGPoint(x: 4, y: 4), size: CGSize(width: gifLabelSize.width * 1.25, height: gifLabelSize.height))
        gifLabel.layer.cornerRadius = 3
    }
    
    // MARK: -
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configure()
    }
    
}
