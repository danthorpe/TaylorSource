//
//  Created by Daniel Thorpe on 16/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import XCTest
import Datasources
import TaylorSource
import Nimble

class UITableViewTests: XCTestCase {
    typealias Factory = BasicFactory<Event, UITableViewCell, UITableViewHeaderFooterView, StubbedTableView>

    let view = StubbedTableView()
    let factory = Factory()

    var validIndexPath: NSIndexPath {
        return NSIndexPath(forRow: 0, inSection: 0)
    }

    override func setUp() {
        view.registerClass(UITableViewCell.self, withIdentifier: "cell")
        view.registerClass(UITableViewHeaderFooterView.self, forSupplementaryViewKind: .Header, withIdentifier: "header")
    }

    // Tests

    func test_GivenRegisteredCell_WhenAccessingCellForItem_ThatCellIsReturned() {
        registerCell { (_, _, _) in }
        let cell = factory.cellForItem(Event.create(), inView: view, atIndex: validIndexPath)
        expect(cell).to(beAnInstanceOf(UITableViewCell.self))
    }

    func test_GivenRegisteredCell_WhenAccessingCellForItem_ThatConfigurationBlockIsRun() {
        var blockDidRun = false
        registerCell { (_, _, _) in blockDidRun = true }
        let _ = factory.cellForItem(Event.create(), inView: view, atIndex: validIndexPath)
        expect(blockDidRun).to(beTrue())
    }

    func test_GivenRegisteredHeaderView_WhenAccessingHeader_ThatViewIsReturned() {
        registerHeader { (_, _) in }
        let supplementary = factory.supplementaryViewForKind(.Header, inView: view, atIndex: validIndexPath)
        expect(supplementary).to(beAnInstanceOf(UITableViewHeaderFooterView.self))
    }

    func test_GivenRegisteredHeaderView_WhenAccessingHeader_ThatConfigurationBlockIsRun() {
        var blockDidRun = false
        registerHeader { (_, _) in blockDidRun = true }
        let _ = factory.supplementaryViewForKind(.Header, inView: view, atIndex: validIndexPath)
        expect(blockDidRun).to(beTrue())
    }

    func test_GivenRegisteredHeaderView_WhenAccessingFooter_ThatViewIsNotReturned() {
        var blockDidRun = false
        registerHeader { (_, _) in blockDidRun = true }
        let supplementary = factory.supplementaryViewForKind(.Footer, inView: view, atIndex: validIndexPath)
        expect(supplementary).to(beNil())
        expect(blockDidRun).to(beFalse())
    }

    func test_GivenRegisteredFooterView_WhenAccessingFooter_ThatViewIsReturned() {
        registerFooter { (_, _) in }
        let supplementary = factory.supplementaryViewForKind(.Footer, inView: view, atIndex: validIndexPath)
        expect(supplementary).to(beAnInstanceOf(UITableViewHeaderFooterView.self))
    }

    func test_GivenRegisteredFooterView_WhenAccessingHeader_ThatViewIsNotReturned() {
        var blockDidRun = false
        registerFooter { (_, _) in blockDidRun = true }
        let supplementary = factory.supplementaryViewForKind(.Header, inView: view, atIndex: validIndexPath)
        expect(supplementary).to(beNil())
        expect(blockDidRun).to(beFalse())
    }

    func test_GivenRegisteredCustomView_WhenAccessingCustomView_ThatViewIsReturned() {
        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "sidebar"), kind: .Custom("Sidebar"), inView: view) { (_, _) in }
        let supplementary = factory.supplementaryViewForKind(.Custom("Sidebar"), inView: view, atIndex: validIndexPath)
        expect(supplementary).to(beAnInstanceOf(UITableViewHeaderFooterView.self))
    }

    func test_GivenRegisteredCustomView_WhenAccessingDifferentCustomView_ThatViewIsNotReturned() {
        var blockDidRun = false
        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "sidebar"), kind: .Custom("Left Sidebar"), inView: view) { (_, _) in blockDidRun = true }
        let supplementary = factory.supplementaryViewForKind(.Custom("Right Sidebar"), inView: view, atIndex: validIndexPath)
        expect(supplementary).to(beNil())
        expect(blockDidRun).to(beFalse())
    }

    // Helpers

    func registerCell(key: String? = .None, config: Factory.CellConfiguration) {
        if let key = key {
            factory.registerCell(.ClassWithIdentifier(UITableViewCell.self, "cell"), inView: view, withKey: key, configuration: config)
        }
        else {
            factory.registerCell(.ClassWithIdentifier(UITableViewCell.self, "cell"), inView: view, configuration: config)
        }
    }

    func registerHeader(key: String? = .None, config: Factory.SupplementaryViewConfiguration) {
        if let key = key {
            factory.registerHeaderView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "header"), inView: view, withKey: key, configuration: config)
        }
        else {
            factory.registerHeaderView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "header"), inView: view, configuration: config)
        }
    }

    func registerFooter(key: String? = .None, config: Factory.SupplementaryViewConfiguration) {
        if let key = key {
            factory.registerFooterView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "footer"), inView: view, withKey: key, configuration: config)
        }
        else {
            factory.registerFooterView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "footer"), inView: view, configuration: config)
        }
    }
}

class UICollectionViewTests: XCTestCase {

    typealias Factory = BasicFactory<Event, UICollectionViewCell, UICollectionReusableView, StubbedCollectionView>

    let view = StubbedCollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    let factory = Factory()

    var validIndexPath: NSIndexPath {
        return NSIndexPath(forItem: 0, inSection: 0)
    }

    override func setUp() {
        view.registerClass(UICollectionViewCell.self, withIdentifier: "cell")
        view.registerClass(UICollectionReusableView.self, forSupplementaryViewKind: .Header, withIdentifier: "whatever")
    }

    // Tests

    func test_GivenRegisteredCell_WhenAccessingCellForItem_ThatCellIsReturned() {
        registerCell { (_, _, _) in }
        let cell = factory.cellForItem(Event.create(), inView: view, atIndex: validIndexPath)
        XCTAssertNotNil(cell, "Cell should be returned")
    }

    func test_GivenRegisteredCell_WhenAccessingCellForItem_ThatConfigurationBlockIsRun() {
        var blockDidRun = false
        registerCell { (_, _, _) in blockDidRun = true }
        let cell = factory.cellForItem(Event.create(), inView: view, atIndex: validIndexPath)
        XCTAssertTrue(blockDidRun, "Configuration block was not run.")
    }

    func test_GivenRegisteredHeaderView_WhenAccessingHeader_ThatViewIsReturned() {
        registerHeader { (_, _) in }
        let supplementary = factory.supplementaryViewForKind(.Header, inView: view, atIndex: validIndexPath)
        XCTAssertNotNil(supplementary, "View should be returned.")
    }

    func test_GivenRegisteredHeaderView_WhenAccessingHeader_ThatConfigurationBlockIsRun() {
        var blockDidRun = false
        registerHeader { (_, _) in blockDidRun = true }
        let supplementary = factory.supplementaryViewForKind(.Header, inView: view, atIndex: validIndexPath)
        XCTAssertTrue(blockDidRun, "Configuration block was not run.")
    }

    func test_GivenRegisteredHeaderView_WhenAccessingFooter_ThatViewIsNotReturned() {
        var blockDidRun = false
        registerHeader { (_, _) in blockDidRun = true }
        let supplementary = factory.supplementaryViewForKind(.Footer, inView: view, atIndex: validIndexPath)
        XCTAssertNil(supplementary, "No view should be returned.")
        XCTAssertFalse(blockDidRun, "Configuration block should not have been run.")
    }

    func test_GivenRegisteredFooterView_WhenAccessingFooter_ThatViewIsReturned() {
        registerFooter { (_, _) in }
        let supplementary = factory.supplementaryViewForKind(.Footer, inView: view, atIndex: validIndexPath)
        XCTAssertNotNil(supplementary, "View should be returned.")
    }

    func test_GivenRegisteredFooterView_WhenAccessingHeader_ThatViewIsNotReturned() {
        var blockDidRun = false
        registerFooter { (_, _) in blockDidRun = true }
        let supplementary = factory.supplementaryViewForKind(.Header, inView: view, atIndex: validIndexPath)
        XCTAssertNil(supplementary, "No view should be returned.")
        XCTAssertFalse(blockDidRun, "Configuration block should not have been run.")
    }

    func test_GivenRegisteredCustomView_WhenAccessingCustomView_ThatViewIsReturned() {
        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "sidebar"), kind: .Custom("Sidebar"), inView: view) { (_, _) in }
        let supplementary = factory.supplementaryViewForKind(.Custom("Sidebar"), inView: view, atIndex: validIndexPath)
        XCTAssertNotNil(supplementary, "View should be returned.")
    }

    func test_GivenRegisteredCustomView_WhenAccessingDifferentCustomView_ThatViewIsNotReturned() {
        var blockDidRun = false
        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "sidebar"), kind: .Custom("Left Sidebar"), inView: view) { (_, _) in blockDidRun = true }
        let supplementary = factory.supplementaryViewForKind(.Custom("Right Sidebar"), inView: view, atIndex: validIndexPath)
        XCTAssertNil(supplementary, "No view should be returned.")
        XCTAssertFalse(blockDidRun, "Configuration block should not have been run.")
    }
    
    // MARK: Helpers

    func registerCell(key: String? = .None, config: Factory.CellConfiguration) {
        if let key = key {
            factory.registerCell(.ClassWithIdentifier(UICollectionViewCell.self, "cell"), inView: view, withKey: key, configuration: config)
        }
        else {
            factory.registerCell(.ClassWithIdentifier(UICollectionViewCell.self, "cell"), inView: view, configuration: config)
        }
    }

    func registerHeader(key: String? = .None, config: Factory.SupplementaryViewConfiguration) {
        if let key = key {
            factory.registerHeaderView(.ClassWithIdentifier(UICollectionReusableView.self, "header"), inView: view, withKey: key, configuration: config)
        }
        else {
            factory.registerHeaderView(.ClassWithIdentifier(UICollectionReusableView.self, "header"), inView: view, configuration: config)
        }
    }

    func registerFooter(key: String? = .None, config: Factory.SupplementaryViewConfiguration) {
        if let key = key {
            factory.registerFooterView(.ClassWithIdentifier(UICollectionReusableView.self, "footer"), inView: view, withKey: key, configuration: config)
        }
        else {
            factory.registerFooterView(.ClassWithIdentifier(UICollectionReusableView.self, "footer"), inView: view, configuration: config)
        }
    }
}

