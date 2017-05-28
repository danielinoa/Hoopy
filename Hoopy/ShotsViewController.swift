//
//  ShotsViewController.swift
//  Hoopy
//
//  Created by Daniel Inoa on 9/17/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

final class ShotsViewController: UICollectionViewController, ShotsCarouselViewControllerDataSource, UICollectionViewDelegateFlowLayout, ShotsLayoutManagerDelegate {
    
    private lazy var favoritesBarButtonItem: UIBarButtonItem = {
        let heartImage = UIImage(named: "heart-filled")
        let item = UIBarButtonItem(image: heartImage, style: .plain, target: self, action: #selector(favoritesBarButtonTapped))
        return item
    }()
    
    private lazy var settingsBarButtonItem: UIBarButtonItem = {
        let image = UIImage(named: "settings")
        let item = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(settingsBarButtonTapped))
        return item
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let items: [String] = DribbbleDataSource.Category.all.map { $0.rawValue }
        let control = UISegmentedControl(items: items)
        control.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        let font = UIFont.systemFont(ofSize: 12).smallCaps
        control.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        return control
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        control.tintColor = UIColor(hexString: "#FF0080")
        return control
    }()
    
    private var shotsLayoutManager: ShotsLayoutManager {
        let manager = ShotsLayoutManager.shared
        manager.addDelegate(delegate: self)
        return manager
    }
    
    // MARK: - Data Source
    
    /**
     TODO: Refactor such that each category maps to a collection view and a data source
     */
    private(set) var dataSource: DribbbleDataSource!
    private let dataSources: [DribbbleDataSource] = {
        let categories = DribbbleDataSource.Category.all.map { DribbbleDataSource(category: $0) }
        return categories
    }()
    
    private var shots: [DribbbleShot] {
        return dataSource.shots
    }
    
    private func reloadDataSources() {
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
    
    private func scroll(to shot: DribbbleShot) {
        guard let shotIndex = shots.index(of: shot) else { return }
        let shotIndexPath = IndexPath(row: shotIndex, section: 0)
        collectionView?.scrollToItem(at: shotIndexPath, at: .bottom, animated: true)
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
        if indexPath.row < shots.count {
            let shot = shots[indexPath.row]
            collectionCell.configure(with: shot)
        }
        return collectionCell
    }
    
    // MARK: - Collection Delegate
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if presentedViewController == nil {
            retrieveNewShots(forShotIndex: indexPath.row)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let shot = shots[indexPath.row]
        
        let cell = (collectionView.cellForItem(at: indexPath) as? ShotCollectionCell)
        let placeholderImage = cell?.imageView.image
        
        let carouselViewController = ShotsCarouselViewController(shot: shot, placeholderImage: placeholderImage)
        carouselViewController.dataSource = self
        carouselViewController.modalPresentationStyle = .overCurrentContext
        carouselViewController.modalTransitionStyle = .crossDissolve
        present(carouselViewController, animated: false, completion: nil)
    }
    
    // MARK: - Refresh
    
    @objc private func refresh(_ sender: AnyObject?) {
        dataSource.reset()
        dataSource.loadCurrentPageOfShots { _ in
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - Pagination
    
    /**
     Retrieves and inserts new shots in the collection.
     */
    private func retrieveNewShots(forShotIndex index: Int) {
        let shouldRetrieveMoreShots = index >= shots.count - 4
        if let collectionView = collectionView, shouldRetrieveMoreShots {
            // This is a workaround. http://stackoverflow.com/questions/18796891/uicollectionview-reloaddata-not-functioning-properly-in-ios-7
            dataSource.loadNextPageOfShots { _ in
                DispatchQueue.main.async {
                    collectionView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Categories
    
    @objc private func segmentedControlChanged(_ control: UISegmentedControl) {
        guard segmentedControl == control else { return }
        dataSource = dataSources[segmentedControl.selectedSegmentIndex]
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    // MARK: - ShotsCarouselViewControllerDataSource
    
    func shotBefore(shot: DribbbleShot, in: ShotsCarouselViewController) -> DribbbleShot? {
        guard let shotIndex = shots.index(of: shot),
            let previousShot = shots.element(before: shotIndex) else { return nil }
        scroll(to: previousShot)
        return previousShot
    }
    
    func shotAfter(shot: DribbbleShot, in: ShotsCarouselViewController) -> DribbbleShot? {
        guard let shotIndex = shots.index(of: shot),
            let nextShot = shots.element(after: shotIndex) else { return nil }
        retrieveNewShots(forShotIndex: shotIndex)
        scroll(to: nextShot)
        return nextShot
    }
    
    func placeholderImage(for shot: DribbbleShot, in: ShotsCarouselViewController) -> UIImage? {
        guard let shotIndex = dataSource.shots.index(of: shot) else { return nil }
        let indexPath = IndexPath(row: shotIndex, section: 0)
        let cell = collectionView?.cellForItem(at: indexPath) as? ShotCollectionCell
        let placeholderImage = cell?.imageView.image
        return placeholderImage
    }
    
    // MARK: - Collection Layout & ShotsLayoutManagerDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return shotsLayoutManager.shotCollectionCellSize(in: collectionView, for: collectionViewLayout)
    }
    
    func shotsLayoutManagerDidChangeLayout(manager: ShotsLayoutManager) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
}
