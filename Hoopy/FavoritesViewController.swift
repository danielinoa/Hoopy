//
//  FavoritesViewController.swift
//  Hoopy
//
//  Created by Daniel Inoa on 9/19/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

final class FavoritesViewController: UICollectionViewController, ShotsCarouselViewControllerDataSource, ShotsCarouselViewControllerDelegate {
    
    private var shots: [DribbbleShot] = DribbbleShot.loadFavoriteShots().reversed() {
        didSet {
            collectionView?.reloadData()
            updateDisplayOfEmptyShotsView()
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16).smallCaps
        label.text = "favorites"
        label.textColor = UIColor(hexString: "#FF0080")
        return label
    }()
    
    let emptyShotsView = EmptyShotsView.instanceFromNib()
    
    var shotsLayoutManager: ShotsLayoutManager {
        let manager = ShotsLayoutManager.shared
        manager.addDelegate(delegate: self)
        return manager
    }
    
    // MARK: - Lifecycle

    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.init(collectionViewLayout: layout)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.register(ShotCollectionCell.self, forCellWithReuseIdentifier: ShotCollectionCell.reuseIdentifier)
        collectionView?.addSubview(emptyShotsView)
        
        navigationItem.titleView = titleLabel
        navigationItem.titleView?.sizeToFit()
        
        updateDisplayOfEmptyShotsView()
    }
    
    // MARK: - 
    
    private func updateDisplayOfEmptyShotsView() {
        emptyShotsView.isHidden = !shots.isEmpty
        collectionView?.isScrollEnabled = !shots.isEmpty
        if shots.isEmpty {
            collectionView?.bringSubview(toFront: emptyShotsView)
        } else {
            collectionView?.sendSubview(toBack: emptyShotsView)
        }
    }

    // MARK: Collection Data Source

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shots.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: ShotCollectionCell.reuseIdentifier, for: indexPath) as? ShotCollectionCell else {
            fatalError()
        }
        collectionCell.configure(with: shots[indexPath.row])
        return collectionCell
    }
    
    // MARK: - Collection Delegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let shot = shots[indexPath.row]
        
        let cell = (collectionView.cellForItem(at: indexPath) as? ShotCollectionCell)
        let placeholderImage = cell?.imageView.image
        
        let carouselViewController = ShotsCarouselViewController(shot: shot, placeholderImage: placeholderImage)
        
        carouselViewController.dataSource = self
        carouselViewController.delegate = self
        carouselViewController.modalPresentationStyle = .overCurrentContext
        carouselViewController.modalTransitionStyle = .crossDissolve
        present(carouselViewController, animated: false, completion: nil)
    }
    
    // MARK: - Collection Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let collectionView = collectionView {
            emptyShotsView.frame = collectionView.bounds
        }
    }
    
    // MARK: - ShotsCarouselViewControllerDataSource
    
    func shotBefore(shot: DribbbleShot, in: ShotsCarouselViewController) -> DribbbleShot? {
        if let shotIndex = shots.index(of: shot),
            shotIndex - 1 >= 0 {
            let previousShot = shots[shotIndex - 1]
            return previousShot
        }
        return nil
    }
    
    func shotAfter(shot: DribbbleShot, in: ShotsCarouselViewController) -> DribbbleShot? {
        if let shotIndex = shots.index(of: shot),
            shotIndex + 1 < shots.count {
            let nextShot = shots[shotIndex + 1]
            return nextShot
        }
        return nil
    }
    
    func placeholderImage(for shot: DribbbleShot, in: ShotsCarouselViewController) -> UIImage? {
        if let shotIndex = shots.index(of: shot) {
            let indexPath = IndexPath(row: shotIndex, section: 0)
            let cell = (collectionView?.cellForItem(at: indexPath) as? ShotCollectionCell)
            let placeholderImage = cell?.imageView.image
            return placeholderImage
        }
        return nil
    }
    
    // MARK: - ShotsCarouselViewControllerDelegate
    
    func favoriteToggled(shot: DribbbleShot, in: ShotsCarouselViewController) {
        shots = DribbbleShot.loadFavoriteShots().reversed()
    }

}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout, ShotsLayoutManagerDelegate {
    
    // MARK: - Collection Layout & ShotsLayoutManagerDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return shotsLayoutManager.shotCollectionCellSize(in: collectionView, for: collectionViewLayout)
    }
    
    func shotsLayoutManagerDidChangeLayout(manager: ShotsLayoutManager) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
}
