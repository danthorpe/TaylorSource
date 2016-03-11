//
//  FactoryTests.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 11/03/2016.
//
//

import XCTest
@testable import TaylorSource

typealias TestableFactory = Factory<String, UITableViewCell, UITableViewHeaderFooterView, UITableView, NSIndexPath, NSIndexPath>

class FactoryTests: XCTestCase {

    var factory: TestableFactory!
    var tableView: UITableView!
    var identifier: String!
    var indexPath: NSIndexPath!
    var cell: UITableViewCell!
    var supplementaryView: UITableViewHeaderFooterView!

    override func setUp() {
        super.setUp()
        factory = TestableFactory()
        tableView = UITableView()
        identifier = "An Identifier"
        indexPath = NSIndexPath(forRow: 0, inSection: 0)
        cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
        supplementaryView = UITableViewHeaderFooterView(reuseIdentifier: identifier)
    }

    override func tearDown() {
        factory = nil
        tableView = nil
        identifier = nil
        indexPath = nil
        cell = nil
        supplementaryView = nil
        super.tearDown()
    }
}

class FactoryCellRegistrarTypeTests: FactoryTests {

    func test__defaultCellKey() {
        XCTAssertEqual(factory.defaultCellKey, "Default Cell Key")
    }

    func test__registerCell() {
        var didExecuteConfiguration = false

        factory.registerCell(.ClassWithIdentifier(UITableViewCell.self, identifier), inView: tableView) { cell, item, index in
            didExecuteConfiguration = true
        }

        guard let (identifier, configuration) = factory.cells[factory.defaultCellKey] else {
            XCTFail("Cell not registered"); return
        }

        XCTAssertEqual(identifier, self.identifier)
        configuration(cell: cell, item: "The Item", index: indexPath)
        XCTAssertTrue(didExecuteConfiguration)
    }
}

class FactorySupplementaryViewRegistrarTypeTests: FactoryTests {

    func test__defaultSupplementaryKey() {
        XCTAssertEqual(factory.defaultSupplementaryKey, "Default Suppplementary View Key")
    }

    func test__defaultSupplementaryIndexForKind() {
        let kind: SupplementaryElementKind = .Header
        let index = factory.defaultSupplementaryIndexForKind(kind)
        XCTAssertEqual(index.key, factory.defaultSupplementaryKey)
        XCTAssertEqual(index.kind, kind)
    }

    func test__registerSupplementaryView() {
        var didExecuteConfiguration = false

        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, identifier), kind: .Header, inView: tableView) { supplementaryView, index in
            didExecuteConfiguration = true
        }

        guard let (identifier, configuration) = factory.views[SupplementaryElementIndex(kind: .Header, key: factory.defaultSupplementaryKey)] else {
            XCTFail("View not registered"); return
        }

        XCTAssertEqual(identifier, self.identifier)
        configuration(supplementaryView: supplementaryView, index: indexPath)
        XCTAssertTrue(didExecuteConfiguration)
    }
}

class SupplementaryElementKindTests: XCTestCase {

    var kind: SupplementaryElementKind!

    func test__init_collectionViewHeader() {
        kind = SupplementaryElementKind(UICollectionElementKindSectionHeader)
        XCTAssertEqual(kind, SupplementaryElementKind.Header)
    }

    func test__init_collectionViewFooter() {
        kind = SupplementaryElementKind(UICollectionElementKindSectionFooter)
        XCTAssertEqual(kind, SupplementaryElementKind.Footer)
    }

    func test__init_custom() {
        let custom = "A custom element"
        kind = SupplementaryElementKind(custom)
        XCTAssertEqual(kind, SupplementaryElementKind.Custom(custom))
    }
}

class ReusableViewDescriptorTests: XCTestCase {

    var identifier: String!
    var descriptor: ReusableViewDescriptor!

    override func setUp() {
        super.setUp()
        identifier = "An Identifier"
    }

    override func tearDown() {
        identifier = nil
        super.tearDown()
    }

    func test__identifier_nibWithIdentifier() {
        descriptor = .NibWithIdentifier(UINib(), identifier)
        XCTAssertEqual(descriptor.identifier, identifier)
    }

    func test__identifier_classWithIdentifier() {
        descriptor = .ClassWithIdentifier(UITableViewCell.self, identifier)
        XCTAssertEqual(descriptor.identifier, identifier)
    }

    func test__identifier_dynamicWithIdentifier() {
        descriptor = .DynamicWithIdentifier(identifier)
        XCTAssertEqual(descriptor.identifier, identifier)
    }
}
