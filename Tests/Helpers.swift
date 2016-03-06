//
//  Helpers.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 20/02/2016.
//
//

import UIKit
@testable import TaylorSource

class TestableCellBasedView<Cell, SupplementaryView>: TestableCellBasedViewType {

    var didRegisterNibWithIdentifier: (nib: UINib, identifier: String)? = .None
    var didRegisterClassWithIdentifier: (aClass: AnyClass, identifier: String)? = .None
    var didDequeueCellWithIdentifier: (id: String, indexPath: NSIndexPath)? = .None

    var didRegisterNibForKindWithIdentifier: (nib: UINib, kind: SupplementaryElementKind, identifier: String)? = .None
    var didRegisterClassForKindWithIdentifier: (aClass: AnyClass, kind: SupplementaryElementKind, identifier: String)? = .None
    var didDequeueSupplementaryViewWithIdentifier: (id: String, kind: SupplementaryElementKind, indexPath: NSIndexPath)? = .None

    var didReloadData = false

    var cell: Cell! = nil
    var supplementaryView: SupplementaryView? = .None

    required init() { }

    func registerNib(nib: UINib, withIdentifier reuseIdentifier: String) {
        didRegisterNibWithIdentifier = (nib, reuseIdentifier)
    }

    func registerClass(aClass: AnyClass, withIdentifier reuseIdentifier: String) {
        didRegisterClassWithIdentifier = (aClass, reuseIdentifier)
    }

    func dequeueCellWithIdentifier(id: String, atIndexPath indexPath: NSIndexPath) -> Cell {
        didDequeueCellWithIdentifier = (id, indexPath)
        return cell
    }

    func registerNib(nib: UINib, forSupplementaryViewKind kind: SupplementaryElementKind, withIdentifier reuseIdentifier: String) {
        didRegisterNibForKindWithIdentifier = (nib, kind, reuseIdentifier)
    }

    func registerClass(aClass: AnyClass, forSupplementaryViewKind kind: SupplementaryElementKind, withIdentifier reuseIdentifier: String) {
        didRegisterClassForKindWithIdentifier = (aClass, kind, reuseIdentifier)
    }

    func dequeueSupplementaryViewWithIdentifier(id: String, kind: SupplementaryElementKind, atIndexPath indexPath: NSIndexPath) -> SupplementaryView? {
        didDequeueSupplementaryViewWithIdentifier = (id, kind, indexPath)
        return supplementaryView
    }

    func reloadData() {
        didReloadData = true
    }
}



