//
//  ShotsViewController.swift
//  Hoopy
//
//  Created by Daniel Inoa on 9/17/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

final class ShotsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet fileprivate weak var layoutBarButtonItem: UIBarButtonItem!
    
    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let items: [String] = DribbbleDataSource.Category.all.map { $0.rawValue }
        let control = UISegmentedControl(items: items)
        control.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        control.tintColor = UIColor(hexString: "#FF0080")
        let font = UIFont.systemFont(ofSize: 12).smallCaps
        control.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        return control
    }()
    
    fileprivate lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        control.tintColor = .white
        return control
    }()
    
    // MARK: - DataSource
    
    /**
     Refactor such that each category maps to a collection view and a data source
     */
    fileprivate(set) var dataSource: DribbbleDataSource!
    fileprivate let dataSources: [DribbbleDataSource] = {
        let categories = DribbbleDataSource.Category.all.map { DribbbleDataSource(category: $0) }
        return categories
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutBarButtonItem.title = " ◉"
        layoutBarButtonItem.tintColor = UIColor(hexString: "#FF0080")
        collectionView?.refreshControl = refreshControl
        navigationItem.titleView = segmentedControl
        segmentedControl.selectedSegmentIndex = 0
        
        dataSource = dataSources.first!
        dataSources.forEach({ dataSource in
            dataSource.loadCurrentPageOfShots(completion: { _ in
                if self.dataSource === dataSource {
                    DispatchQueue.main.async { self.collectionView?.reloadData() }
                }
            })
        })
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
    
    // MARK: - Layout
    
    fileprivate var numberOfCellsInRow = 3 {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let linesBetweenCells = numberOfCellsInRow - 1
        var horizontalSpacing: CGFloat = 0
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            horizontalSpacing = flowLayout.minimumInteritemSpacing
        }
        let dimension = (collectionView.bounds.width - horizontalSpacing * CGFloat(linesBetweenCells) ) / CGFloat(numberOfCellsInRow)
        return CGSize(width: dimension, height: dimension)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func layoutBarButtonItemTapped(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Layout", message: "Number of shots per row", preferredStyle: .actionSheet)
        let action2 = UIAlertAction(title: "2 shots", style: .default) { _ in
            self.numberOfCellsInRow = 2
        }
        let action3 = UIAlertAction(title: "3 shots", style: .default) { _ in
            self.numberOfCellsInRow = 3
        }
        let action1 = UIAlertAction(title: "4 shots", style: .default) { _ in
            self.numberOfCellsInRow = 4
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(action2)
        alertController.addAction(action3)
        alertController.addAction(action1)
        alertController.addAction(cancelAction)
        present(alertController, animated: true) {}
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
