//
//  Testable.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 03/04/2016.
//  Copyright © 2016 Daniel Thorpe. All rights reserved.
//

import XCTest
@testable import TaylorSource

class TestCell: UITableViewCell, ReusableViewType {
    static let reuseIdentifier = "Test Cell Identifier"
}

class TestTableViewHeader: UITableViewHeaderFooterView, ReusableViewType {
    static let reuseIdentifier = "Test Header View Identifier"
}

class TestableTable: UITableView {

    var didRegisterClassWithIdentifier: (AnyClass?, String)? = .None
    var didRegisterNibWithIdentifier: (UINib?, String)? = .None

    var didRegisterSupplementaryClassWithIdentifier: (AnyClass?, String)? = .None
    var didRegisterSupplementaryNibWithIdentifier: (UINib?, String)? = .None

    override func registerClass(cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        didRegisterClassWithIdentifier = (cellClass, identifier)
        super.registerClass(cellClass, forCellReuseIdentifier: identifier)
    }

    override func registerNib(nib: UINib?, forCellReuseIdentifier identifier: String) {
        didRegisterNibWithIdentifier = (nib, identifier)
        super.registerNib(nib, forCellReuseIdentifier: identifier)
    }

    override func registerClass(aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
        didRegisterClassWithIdentifier = (aClass, identifier)
        super.registerClass(aClass, forHeaderFooterViewReuseIdentifier: identifier)
    }

    override func registerNib(nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) {
        didRegisterSupplementaryNibWithIdentifier = (nib, identifier)
        super.registerNib(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }

    override func dequeueReusableCellWithIdentifier(identifier: String, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell(style: .Default, reuseIdentifier: identifier)
    }

    override func dequeueReusableHeaderFooterViewWithIdentifier(identifier: String) -> UITableViewHeaderFooterView? {
        return UITableViewHeaderFooterView(reuseIdentifier: identifier)
    }
}

