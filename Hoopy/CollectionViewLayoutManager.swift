//
//  Created by Daniel Inoa on 9/24/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

protocol ShotsLayoutManagerDelegate: NSObjectProtocol {
    func shotsLayoutManagerDidChangeLayout(manager: ShotsLayoutManager)
}

class ShotsLayoutManager: NSObject, UICollectionViewDelegateFlowLayout {
    
    static let shared = ShotsLayoutManager()
    
    private var delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
    var shotsInRow: Int {
        get {
            let numShots = UserDefaults.standard.integer(forKey: "shotsInRow")
            return numShots < 2 ? 3 : numShots
        }
        set {
            delegates.allObjects.forEach({ ($0 as? ShotsLayoutManagerDelegate)?.shotsLayoutManagerDidChangeLayout(manager: self)  })
            UserDefaults.standard.set(newValue, forKey: "shotsInRow")
        }
    }
    
    func shotCollectionCellSize(in collectionView: UICollectionView, for layout: UICollectionViewLayout) -> CGSize {
        let linesBetweenCells = shotsInRow - 1
        var horizontalSpacing: CGFloat = 0
        if let flowLayout = layout as? UICollectionViewFlowLayout {
            horizontalSpacing = flowLayout.minimumInteritemSpacing
        }
        let dimension = (collectionView.bounds.width - horizontalSpacing * CGFloat(linesBetweenCells) ) / CGFloat(shotsInRow)
        return CGSize(width: dimension, height: dimension)
    }
    
    func addDelegate(delegate: ShotsLayoutManagerDelegate) {
        delegates.add(delegate)
    }
    
    func removeDelegate(delegate: ShotsLayoutManagerDelegate) {
        delegates.remove(delegate)
    }
    
}
