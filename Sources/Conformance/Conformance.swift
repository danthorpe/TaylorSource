//
//  Conformance.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 20/02/2016.
//
//

import UIKit

/**
 Utility function to load a Nib
 
 - parameter owner: a AnyObject? to act as the file owner
 - parameter options: a [NSObject: AnyObject]? options dictionary
 - returns: a
 */
public func loadReusableViewFromNib<T: UIView where T: ReusableViewType>(owner: AnyObject? = .None, options: [NSObject: AnyObject]? = .None) -> T? {
    return NSBundle(forClass: T.self).loadNibNamed(T.reuseIdentifier, owner: owner, options: options).last as? T
}


extension NSIndexPath: IndexPathIndexType {

    public var indexPath: NSIndexPath {
        return self
    }
}

// MARK: - UITableView

extension UITableView: ReusableCellBasedViewType {

    public func registerNib(nib: UINib, withIdentifier reuseIdentifier: String) {
        registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
    }

    public func registerClass(aClass: AnyClass, withIdentifier reuseIdentifier: String) {
        registerClass(aClass, forCellReuseIdentifier: reuseIdentifier)
    }

    public func dequeueCellWithIdentifier(identifier: String, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
    }
}

extension UITableView: ReusableSupplementaryViewBasedViewType {

    public func registerNib(nib: UINib, forSupplementaryViewKind kind: SupplementaryElementKind, withIdentifier reuseIdentifier: String) {
        registerNib(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }

    public func registerClass(aClass: AnyClass, forSupplementaryViewKind kind: SupplementaryElementKind, withIdentifier reuseIdentifier: String) {
        registerClass(aClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }

    public func dequeueSupplementaryViewWithIdentifier(identifier: String, kind: SupplementaryElementKind, atIndexPath indexPath: NSIndexPath) -> UITableViewHeaderFooterView? {
        return dequeueReusableHeaderFooterViewWithIdentifier(identifier)
    }
}

extension UITableView: CellBasedViewType { }

// MARK: - UICollectionView
