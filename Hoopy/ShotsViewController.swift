//
//  ShotsViewController.swift
//  Hoopy
//
//  Created by Daniel Inoa on 9/17/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

final class ShotsViewController: UICollectionViewController {
    
    private lazy var favoritesBarButtonItem: UIBarButtonItem = {
        let heartImage = UIImage(named: "heart-filled")
        let item = UIBarButtonItem(image: heartImage, style: .plain, target: self, action: #selector(favoritesBarButtonTapped))
        item.imageInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return item
    }()
    
    private lazy var settingsBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem.init(title: "◉", style: .plain, target: self, action: #selector(settingsBarButtonTapped))
        return item
    }()
    
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
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.init(collectionViewLayout: layout)
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: ShotsSortCategory.defaultCategoryKey)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.register(ShotCollectionCell.self, forCellWithReuseIdentifier: ShotCollectionCell.reuseIdentifier)
        collectionView?.refreshControl = refreshControl
        
        navigationItem.leftBarButtonItem = settingsBarButtonItem
        navigationItem.rightBarButtonItem = favoritesBarButtonItem
        navigationItem.titleView = segmentedControl
        segmentedControl.selectedSegmentIndex = 0
        
        UserDefaults.standard.addObserver(self, forKeyPath: ShotsSortCategory.defaultCategoryKey, options: [.new], context: nil)
        shotsLayoutManager.addDelegate(delegate: self)
        
        reloadDataSources()
    }
    
    // MARK: -
    
    @objc private func favoritesBarButtonTapped() {
        let favoritesViewController = FavoritesViewController()
        show(favoritesViewController, sender: nil)
    }
    
    @objc private func settingsBarButtonTapped() {
        let settingsViewController = SettingsViewController()
        settingsViewController.modalPresentationStyle = .overCurrentContext
        present(settingsViewController, animated: false, completion: nil)
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
        return dataSource?.shots.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: ShotCollectionCell.reuseIdentifier, for: indexPath) as? ShotCollectionCell else {
            fatalError()
        }
        // Make sure the current row exists within the number of shots, in case the dataSource changes asynchronously.
        if indexPath.row < dataSource.shots.count {
            let shot = dataSource.shots[indexPath.row]
            collectionCell.configure(with: shot)
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let shot = dataSource.shots[indexPath.row]
        let placeholderImage = (collectionView.cellForItem(at: indexPath) as? ShotCollectionCell)?.imageView.image
        
        let shotViewController = ShotViewController(shot: shot, placeholderImage: placeholderImage)
        shotViewController.modalPresentationStyle = .overCurrentContext
        
        present(shotViewController, animated: false, completion: nil)
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
