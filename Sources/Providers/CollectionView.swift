//
//  CollectionView.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 11/04/2016.
//  Copyright © 2016 Daniel Thorpe. All rights reserved.
//

import UIKit

/**
 Providers which can create (and provide) a UICollectionViewDataSource
 object should conform to this protocol.
 */
public protocol UICollectionViewDataSourceProvider {
    
    /// - returns: an object which conforms to UICollectionViewDataSource
    var collectionViewDataSource: UICollectionViewDataSource { get }
}

public protocol CollectionViewType: CellBasedViewType { }

extension UICollectionView: CollectionViewType {
    public typealias CellIndex = NSIndexPath
    public typealias SupplementaryIndex = NSIndexPath
}
