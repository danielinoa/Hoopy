//
//  ShotsViewController.swift
//  Hoopy
//
//  Created by Daniel Inoa on 9/17/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

final class ShotsViewController: UICollectionViewController {
    
    @IBOutlet fileprivate weak var layoutBarButtonItem: UIBarButtonItem!
    @IBOutlet fileprivate weak var favoritesBarButtonItem: UIBarButtonItem!
    
    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let items: [String] = DribbbleDataSource.Category.all.map { $0.rawValue }
        let control = UISegmentedControl(items: items)
        control.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        let font = UIFont.systemFont(ofSize: 12).smallCaps
        control.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        return control
    }()
    
    fileprivate lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        control.tintColor = UIColor(hexString: "#FF0080")
        return control
    }()
    
    fileprivate var shotsLayoutManager: ShotsLayoutManager {
        let manager = ShotsLayoutManager.shared
        manager.addDelegate(delegate: self)
        return manager
    }
    
    // MARK: - Data Source
    
    /**
     Refactor such that each category maps to a collection view and a data source
     */
    fileprivate(set) var dataSource: DribbbleDataSource!
    fileprivate let dataSources: [DribbbleDataSource] = {
        let categories = DribbbleDataSource.Category.all.map { DribbbleDataSource(category: $0) }
        return categories
    }()
    
    fileprivate func reloadDataSources() {
        dataSource = dataSources[segmentedControl.selectedSegmentIndex]
        dataSources.forEach({ dataSource in
            dataSource.reset()
            dataSource.loadCurrentPageOfShots(completion: { _ in
                if self.dataSource === dataSource {
                    DispatchQueue.main.async { self.collectionView?.reloadData() }
                }
            })
        })
    }
    
    // MARK: - Lifecycle
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: ShotsSortCategory.defaultCategoryKey)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.addObserver(self, forKeyPath: ShotsSortCategory.defaultCategoryKey, options: [.new], context: nil)
        shotsLayoutManager.addDelegate(delegate: self)
        navigationController?.navigationBar.tintColor = UIColor(hexString: "#FF0080")
        layoutBarButtonItem.title = "◉"
        collectionView?.refreshControl = refreshControl
        navigationItem.titleView = segmentedControl
        segmentedControl.selectedSegmentIndex = 0
        reloadDataSources()
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // FIXME: This is being called twice.  ¯\_(ツ)_/¯
        if keyPath == ShotsSortCategory.defaultCategoryKey {
            reloadDataSources()
        }
    }
    
    // MARK: - Collection Data Source
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.shots.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "shotCollectionCell", for: indexPath) as? ShotCollectionCell else {
            fatalError()
        }
        // Make sure the current row exists within the number of shots, in case the dataSource changes asynchronously.
        if indexPath.row < dataSource.shots.count {
            collectionCell.configure(with: dataSource.shots[indexPath.row])
        }
        return collectionCell
    }
    
    // MARK: - Collection Delegate
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == dataSource.shots.count - 4 {
            // This is a workaround. http://stackoverflow.com/questions/18796891/uicollectionview-reloaddata-not-functioning-properly-in-ios-7
            dataSource.loadNextPageOfShots(completion: { _ in
                DispatchQueue.main.async {
                    let numRows = collectionView.numberOfItems(inSection: 0)
                    let numOfNewPaths = abs(self.dataSource.shots.count - numRows)
                    var newIndexPaths: [IndexPath] = []
                    for index in 0..<numOfNewPaths {
                        newIndexPaths.append(IndexPath(item: numRows + index, section: 0))
                    }
                    collectionView.reloadData()
                }
            })
        }
    }
    
    // MARK: - Refresh
    
    @objc fileprivate func refresh(_ sender: AnyObject?) {
        dataSource.reset()
        dataSource.loadCurrentPageOfShots { _ in
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - Categories
    
    @objc fileprivate func segmentedControlChanged(_ control: UISegmentedControl) {
        guard segmentedControl == control else { return }
        dataSource = dataSources[segmentedControl.selectedSegmentIndex]
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let shotViewController = segue.destination as? ShotViewController, let selectedIndexPath = collectionView?.indexPathsForSelectedItems?.first {
            shotViewController.dribbbleShot = dataSource.shots[selectedIndexPath.row]
            let placeholderImage = (collectionView?.cellForItem(at: selectedIndexPath) as? ShotCollectionCell)?.imageView.image
            shotViewController.placeholderImage = placeholderImage
        }
    }
    
    
    
}

extension ShotsViewController: UICollectionViewDelegateFlowLayout, ShotsLayoutManagerDelegate {
    
    // MARK: - Collection Layout & ShotsLayoutManagerDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return shotsLayoutManager.shotCollectionCellSize(in: collectionView, for: collectionViewLayout)
    }
    
    func shotsLayoutManagerDidChangeLayout(manager: ShotsLayoutManager) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
}
