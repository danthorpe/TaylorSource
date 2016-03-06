//
//  Conformance.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 20/02/2016.
//
//

import UIKit

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

    public func dequeueCellWithIdentifier(id: String, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return dequeueReusableCellWithIdentifier(id, forIndexPath: indexPath)
    }
}

extension UITableView: ReusableSupplementaryViewBasedViewType {

    public func registerNib(nib: UINib, forSupplementaryViewKind kind: SupplementaryElementKind, withIdentifier reuseIdentifier: String) {
        registerNib(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }

    public func registerClass(aClass: AnyClass, forSupplementaryViewKind kind: SupplementaryElementKind, withIdentifier reuseIdentifier: String) {
        registerClass(aClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }

    public func dequeueSupplementaryViewWithIdentifier(id: String, kind: SupplementaryElementKind, atIndexPath indexPath: NSIndexPath) -> UITableViewHeaderFooterView? {
        return dequeueReusableHeaderFooterViewWithIdentifier(id)
    }
}

extension UITableView: CellBasedViewType { }

// MARK: - UICollectionView
