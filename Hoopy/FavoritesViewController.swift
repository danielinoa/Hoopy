//
//  FavoritesViewController.swift
//  Hoopy
//
//  Created by Daniel Inoa on 9/19/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

final class FavoritesViewController: UICollectionViewController, ShotViewControllerDelegate {
    
    fileprivate var shots: [DribbbleShot] = DribbbleShot.loadFavoriteShots().reversed() {
        didSet {
            collectionView?.reloadData()
            updateDisplayOfEmptyShotsView()
        }
    }
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16).smallCaps
        label.text = "favorites"
        label.textColor = UIColor(hexString: "#FF0080")
        return label
    }()
    
    let emptyShotsView = EmptyShotsView.instanceFromNib()
    
    fileprivate var shotsLayoutManager: ShotsLayoutManager {
        let manager = ShotsLayoutManager.shared
        manager.addDelegate(delegate: self)
        return manager
    }
    
    // MARK: - 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = titleLabel
        navigationItem.titleView?.sizeToFit()
        collectionView?.addSubview(emptyShotsView)
        updateDisplayOfEmptyShotsView()
    }
    
    fileprivate func updateDisplayOfEmptyShotsView() {
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
        guard let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCollectionCell", for: indexPath) as? ShotCollectionCell else {
            fatalError()
        }
        collectionCell.configure(with: shots[indexPath.row])
        return collectionCell
    }
    
    // MARK: - Collection Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let collectionView = collectionView {
            emptyShotsView.frame = collectionView.bounds
        }
    }

    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let shotViewController = segue.destination as? ShotViewController, let selectedIndexPath = collectionView?.indexPathsForSelectedItems?.first {
            shotViewController.delegate = self
            shotViewController.dribbbleShot = shots[selectedIndexPath.row]
            let placeholderImage = (collectionView?.cellForItem(at: selectedIndexPath) as? ShotCollectionCell)?.imageView.image
            shotViewController.placeholderImage = placeholderImage
        }
    }
    
    // MARK: - ShotViewControllerDelegate
    
    func shotViewController(shotViewController: ShotViewController, favoriteToggledShot: DribbbleShot) {
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
