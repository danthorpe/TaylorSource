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

extension NSIndexPath: ConfigurationIndexType {

    public var indexInView: NSIndexPath {
        return self
    }
}

extension Int: ConfigurationIndexType {

    public var indexInView: Int {
        return self
    }
}

// MARK: - UITableView

extension UITableView: ReusableCellBasedViewType {
    public typealias Cell = UITableViewCell

    public func registerNib(nib: UINib, withIdentifier reuseIdentifier: String) {
        registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
    }

    public func registerClass(aClass: AnyClass, withIdentifier reuseIdentifier: String) {
        registerClass(aClass, forCellReuseIdentifier: reuseIdentifier)
    }

    public func dequeueCellWithIdentifier(identifier: String, atIndex index: CellIndex) -> UITableViewCell {
        return dequeueReusableCellWithIdentifier(identifier, forIndexPath: index)
    }
}

extension UITableView: ReusableSupplementaryViewBasedViewType {

    public func registerNib(nib: UINib, forSupplementaryViewKind kind: SupplementaryElementKind, withIdentifier reuseIdentifier: String) {
        registerNib(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }

    public func registerClass(aClass: AnyClass, forSupplementaryViewKind kind: SupplementaryElementKind, withIdentifier reuseIdentifier: String) {
        registerClass(aClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }

    public func dequeueSupplementaryViewWithIdentifier(identifier: String, kind: SupplementaryElementKind, atIndex index: SupplementaryIndex) -> UITableViewHeaderFooterView? {
        return dequeueReusableHeaderFooterViewWithIdentifier(identifier)
    }
}

extension UITableView: CellBasedViewType { }

// MARK: - UICollectionView
