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
    let factory = Factory(cellKey: "cell-key", supplementaryKey: "supplementary-key")

    var validIndexPath: NSIndexPath {
        return NSIndexPath(forRow: 0, inSection: 0)
    }

    override func setUp() {
        view.registerClass(UITableViewCell.self, withIdentifier: "cell")
        view.registerClass(UITableViewHeaderFooterView.self, forSupplementaryViewKind: .Header, withIdentifier: "header")
    }

    // Tests

    func test_GivenRegisteredCell_WhenAccessingCellForItem_ThatCellIsReturned() {
        registerCellWithKey("cell-key") { (_, _, _) in }
        let cell = factory.cellForItem(Event.create(), inView: view, atIndex: validIndexPath)
        expect(cell).to(beAnInstanceOf(UITableViewCell.self))
    }

    func test_GivenRegisteredCell_WhenAccessingCellForItem_ThatConfigurationBlockIsRun() {
        var blockDidRun = false
        registerCellWithKey("cell-key") { (cell, item, index) in blockDidRun = true }
        let _ = factory.cellForItem(Event.create(), inView: view, atIndex: validIndexPath)
        expect(blockDidRun).to(beTrue())
    }

    func test_GivenRegisteredHeaderView_WhenAccessingHeader_ThatViewIsReturned() {
        registerHeaderWithKey("supplementary-key") { (_, _) in }
        let supplementary = factory.supplementaryViewForKind(.Header, inView: view, atIndex: validIndexPath)
        expect(supplementary).to(beAnInstanceOf(UITableViewHeaderFooterView.self))
    }

    func test_GivenRegisteredHeaderView_WhenAccessingHeader_ThatConfigurationBlockIsRun() {
        var blockDidRun = false
        registerHeaderWithKey("supplementary-key") { (view, index) in blockDidRun = true }
        let _ = factory.supplementaryViewForKind(.Header, inView: view, atIndex: validIndexPath)
        expect(blockDidRun).to(beTrue())
    }

    func test_GivenRegisteredHeaderView_WhenAccessingFooter_ThatViewIsNotReturned() {
        var blockDidRun = false
        registerHeaderWithKey("supplementary-key") { (_, _) in blockDidRun = true }
        let supplementary = factory.supplementaryViewForKind(.Footer, inView: view, atIndex: validIndexPath)
        expect(supplementary).to(beNil())
        expect(blockDidRun).to(beFalse())
    }

    func test_GivenRegisteredFooterView_WhenAccessingFooter_ThatViewIsReturned() {
        registerFooterWithKey("supplementary-key") { (_, _) in }
        let supplementary = factory.supplementaryViewForKind(.Footer, inView: view, atIndex: validIndexPath)
        expect(supplementary).to(beAnInstanceOf(UITableViewHeaderFooterView.self))
    }

    func test_GivenRegisteredFooterView_WhenAccessingHeader_ThatViewIsNotReturned() {
        var blockDidRun = false
        registerFooterWithKey("supplementary-key") { (_, _) in blockDidRun = true }
        let supplementary = factory.supplementaryViewForKind(.Header, inView: view, atIndex: validIndexPath)
        expect(supplementary).to(beNil())
        expect(blockDidRun).to(beFalse())
    }

    func test_GivenRegisteredCustomView_WhenAccessingCustomView_ThatViewIsReturned() {
        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "sidebar"), kind: .Custom("Sidebar"), inView: view, withKey: "supplementary-key") { (_, _) in }
        let supplementary = factory.supplementaryViewForKind(.Custom("Sidebar"), inView: view, atIndex: validIndexPath)
        expect(supplementary).to(beAnInstanceOf(UITableViewHeaderFooterView.self))
    }

    func test_GivenRegisteredCustomView_WhenAccessingDifferentCustomView_ThatViewIsNotReturned() {
        var blockDidRun = false
        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "sidebar"), kind: .Custom("Left Sidebar"), inView: view, withKey: "supplementary-key") { (_, _) in blockDidRun = true }
        let supplementary = factory.supplementaryViewForKind(.Custom("Right Sidebar"), inView: view, atIndex: validIndexPath)
        expect(supplementary).to(beNil())
        expect(blockDidRun).to(beFalse())
    }

    // Helpers

    func registerCellWithKey(key: String, config: Factory.CellConfiguration) {
        factory.registerCell(.ClassWithIdentifier(UITableViewCell.self, "cell"), inView: view, withKey: key, configuration: config)
    }

    func registerHeaderWithKey(key: String, config: Factory.SupplementaryViewConfiguration) {
        factory.registerHeaderView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "header"), inView: view, withKey: key, configuration: config)
    }

    func registerFooterWithKey(key: String, config: Factory.SupplementaryViewConfiguration) {
        factory.registerFooterView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "footer"), inView: view, withKey: key, configuration: config)
    }
}

class UICollectionViewTests: XCTestCase {

    typealias Factory = BasicFactory<Event, UICollectionViewCell, UICollectionReusableView, StubbedCollectionView>

    let view = StubbedCollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    let factory = Factory(cellKey: "cell-key", supplementaryKey: "supplementary-key")

    var validIndexPath: NSIndexPath {
        return NSIndexPath(forItem: 0, inSection: 0)
    }

    override func setUp() {
        view.registerClass(UICollectionViewCell.self, withIdentifier: "cell")
        view.registerClass(UICollectionReusableView.self, forSupplementaryViewKind: .Header, withIdentifier: "whatever")
    }

    // Tests

    func test_GivenRegisteredCell_WhenAccessingCellForItem_ThatCellIsReturned() {
        registerCellWithKey("cell-key") { (_, _, _) in }
        let cell = factory.cellForItem(Event.create(), inView: view, atIndex: validIndexPath)
        XCTAssertNotNil(cell, "Cell should be returned")
    }

    func test_GivenRegisteredCell_WhenAccessingCellForItem_ThatConfigurationBlockIsRun() {
        var blockDidRun = false
        registerCellWithKey("cell-key") { (cell, item, index) in blockDidRun = true }
        let cell = factory.cellForItem(Event.create(), inView: view, atIndex: validIndexPath)
        XCTAssertTrue(blockDidRun, "Configuration block was not run.")
    }

    func test_GivenRegisteredHeaderView_WhenAccessingHeader_ThatViewIsReturned() {
        registerHeaderWithKey("supplementary-key") { (_, _) in }
        let supplementary = factory.supplementaryViewForKind(.Header, inView: view, atIndex: validIndexPath)
        XCTAssertNotNil(supplementary, "View should be returned.")
    }

    func test_GivenRegisteredHeaderView_WhenAccessingHeader_ThatConfigurationBlockIsRun() {
        var blockDidRun = false
        registerHeaderWithKey("supplementary-key") { (view, index) in blockDidRun = true }
        let supplementary = factory.supplementaryViewForKind(.Header, inView: view, atIndex: validIndexPath)
        XCTAssertTrue(blockDidRun, "Configuration block was not run.")
    }

    func test_GivenRegisteredHeaderView_WhenAccessingFooter_ThatViewIsNotReturned() {
        var blockDidRun = false
        registerHeaderWithKey("supplementary-key") { (_, _) in blockDidRun = true }
        let supplementary = factory.supplementaryViewForKind(.Footer, inView: view, atIndex: validIndexPath)
        XCTAssertNil(supplementary, "No view should be returned.")
        XCTAssertFalse(blockDidRun, "Configuration block should not have been run.")
    }

    func test_GivenRegisteredFooterView_WhenAccessingFooter_ThatViewIsReturned() {
        registerFooterWithKey("supplementary-key") { (_, _) in }
        let supplementary = factory.supplementaryViewForKind(.Footer, inView: view, atIndex: validIndexPath)
        XCTAssertNotNil(supplementary, "View should be returned.")
    }

    func test_GivenRegisteredFooterView_WhenAccessingHeader_ThatViewIsNotReturned() {
        var blockDidRun = false
        registerFooterWithKey("supplementary-key") { (_, _) in blockDidRun = true }
        let supplementary = factory.supplementaryViewForKind(.Header, inView: view, atIndex: validIndexPath)
        XCTAssertNil(supplementary, "No view should be returned.")
        XCTAssertFalse(blockDidRun, "Configuration block should not have been run.")
    }

    func test_GivenRegisteredCustomView_WhenAccessingCustomView_ThatViewIsReturned() {
        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "sidebar"), kind: .Custom("Sidebar"), inView: view, withKey: "supplementary-key") { (_, _) in }
        let supplementary = factory.supplementaryViewForKind(.Custom("Sidebar"), inView: view, atIndex: validIndexPath)
        XCTAssertNotNil(supplementary, "View should be returned.")
    }

    func test_GivenRegisteredCustomView_WhenAccessingDifferentCustomView_ThatViewIsNotReturned() {
        var blockDidRun = false
        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "sidebar"), kind: .Custom("Left Sidebar"), inView: view, withKey: "supplementary-key") { (_, _) in blockDidRun = true }
        let supplementary = factory.supplementaryViewForKind(.Custom("Right Sidebar"), inView: view, atIndex: validIndexPath)
        XCTAssertNil(supplementary, "No view should be returned.")
        XCTAssertFalse(blockDidRun, "Configuration block should not have been run.")
    }
    // MARK: Helpers

    func registerCellWithKey(key: String, config: Factory.CellConfiguration) {
        factory.registerCell(.ClassWithIdentifier(UICollectionViewCell.self, "cell"), inView: view, withKey: key, configuration: config)
    }

    func registerHeaderWithKey(key: String, config: Factory.SupplementaryViewConfiguration) {
        factory.registerHeaderView(.ClassWithIdentifier(UICollectionReusableView.self, "header"), inView: view, withKey: key, configuration: config)
    }

    func registerFooterWithKey(key: String, config: Factory.SupplementaryViewConfiguration) {
        factory.registerFooterView(.ClassWithIdentifier(UICollectionReusableView.self, "footer"), inView: view, withKey: key, configuration: config)
    }
}

