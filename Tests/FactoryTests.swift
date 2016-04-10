//
//  FactoryTests.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 11/03/2016.
//
//

import XCTest
@testable import TaylorSource

typealias TestableFactory = BasicFactory<TestableTable, UITableViewCell, UITableViewHeaderFooterView, String>

class FactoryTests: XCTestCase {

    var factory: TestableFactory!
    var tableView: TestableFactory.View!
    var cellIdentifier: String!
    var viewIdentifier: String!
    var cellIndex: TestableFactory.CellIndex!
    var supplementaryIndex: TestableFactory.SupplementaryIndex!
    var cell: TestableFactory.Cell!
    var supplementaryView: TestableFactory.SupplementaryView!
    var item: TestableFactory.Item!

    override func setUp() {
        super.setUp()
        factory = TestableFactory()
        tableView = TestableFactory.View()
        cellIdentifier = "Test Cell Identifier"
        viewIdentifier = "Test Header View Identifier"
        cellIndex = NSIndexPath(forRow: 0, inSection: 0)
        supplementaryIndex = 0
        cell = TestableFactory.Cell(style: .Default, reuseIdentifier: cellIdentifier)
        supplementaryView = TestableFactory.SupplementaryView(reuseIdentifier: cellIdentifier)
        item = "Hello World"
    }

    override func tearDown() {
        factory = nil
        tableView = nil
        cellIdentifier = nil
        cellIndex = nil
        cell = nil
        supplementaryView = nil
        super.tearDown()
    }
}

class FactoryCellRegistrarTypeTests: FactoryTests {

    func test__defaultCellKey() {
        XCTAssertEqual(factory.defaultCellKey, "Default Cell Key")
    }

    func test__registerCell__classWithIdentifier__viewRegistersCellWithIdentifier() {
        factory.registerCell(.ClassWithIdentifier(TestableFactory.Cell.self, cellIdentifier), inView: tableView) { _, _, _ in }
        guard let (registeredClass, withIdentifier) = tableView.didRegisterClassWithIdentifier else {
            XCTFail("Table View did not register class with identifier"); return
        }
        XCTAssertNotNil(registeredClass)
        XCTAssertEqual(withIdentifier, cellIdentifier)
    }

    func test__registerCell__nibWithIdentifier__viewRegistersNibWithIdentifier() {
        factory.registerCell(.NibWithIdentifier(TestCell.nib, cellIdentifier), inView: tableView) { _, _, _ in }
        guard let (registeredNib, withIdentifier) = tableView.didRegisterNibWithIdentifier else {
            XCTFail("Table View did not register class with identifier"); return
        }
        XCTAssertNotNil(registeredNib)
        XCTAssertEqual(withIdentifier, cellIdentifier)
    }

    func test__registerCell() {
        var didExecuteConfiguration = false

        factory.registerCell(.ClassWithIdentifier(TestableFactory.Cell.self, cellIdentifier), inView: tableView) { cell, item, index in
            didExecuteConfiguration = true
        }

        guard let (identifier, configuration) = factory.cells[factory.defaultCellKey] else {
            XCTFail("Cell not registered"); return
        }

        XCTAssertEqual(identifier, self.cellIdentifier)
        configuration(cell: cell, item: "The Item", index: cellIndex)
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

    func test__registerSupplementaryView_multipleTimes() {
        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, cellIdentifier), kind: .Header, inView: tableView) { _, _ in }
        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, cellIdentifier), kind: .Footer, inView: tableView) { _, _ in }
        XCTAssertEqual(factory.views.count, 2)
    }

    func test__registerSupplementaryView__classWithIdentifier__viewRegistersCellWithIdentifier() {
        var didExecuteConfiguration = false

        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, cellIdentifier), kind: .Header, inView: tableView) { supplementaryView, index in
            didExecuteConfiguration = true
        }

        guard let (identifier, configuration) = factory.views[SupplementaryElementIndex(kind: .Header, key: factory.defaultSupplementaryKey)] else {
            XCTFail("View not registered"); return
        }

        XCTAssertEqual(identifier, self.cellIdentifier)
        configuration(supplementaryView: supplementaryView, index: supplementaryIndex)
        XCTAssertTrue(didExecuteConfiguration)
    }

    func test__registerSupplementaryView__nibWithIdentifier__viewRegistersNibWithIdentifier() {
        factory.registerSupplementaryView(.NibWithIdentifier(TestTableViewHeader.nib, viewIdentifier), kind: .Header, inView: tableView) { _, _ in }
        guard let (registeredNib, withIdentifier) = tableView.didRegisterSupplementaryNibWithIdentifier else {
            XCTFail("Table View did not register class with identifier"); return
        }
        XCTAssertNotNil(registeredNib)
        XCTAssertEqual(withIdentifier, viewIdentifier)
    }
}

class FactorySupplementaryTextRegistrarTypeTests: FactoryTests {

    func test__registerSupplementaryTextWithKind_multipleTimes() {
        factory.registerSupplementaryTextWithKind(.Header) { "Header text with index: \($0)" }
        factory.registerSupplementaryTextWithKind(.Footer) { "Footer text with index: \($0)" }
        XCTAssertEqual(factory.texts.count, 2)
    }
}

class FactoryCellVendorTypeTests: FactoryTests {

    func test__cellForItem__no_cell_registered__throws_error() {
        XCTAssertThrowsError(try factory.cellForItem(item, inView: tableView, atIndex: cellIndex), TestableFactory.Error.NoCellRegisteredAtIndex(cellIndex))
    }

    func test__cellForItem__configureBlockReceivesCell() {
        factory.registerCell(.ClassWithIdentifier(TestableFactory.Cell.self, cellIdentifier), inView: tableView) { cell, item, index in
            cell.textLabel!.text = item
        }
        let cell = XCTAssertNoThrows(try factory.cellForItem(item, inView: tableView, atIndex: cellIndex))
        XCTAssertEqual(cell.textLabel?.text ?? "Not Correct", item)
    }
}

class FactoryErrorTests: XCTestCase {

    typealias Error = TestableFactory.Error

    var indexPath1: NSIndexPath!
    var indexPath2: NSIndexPath!

    override func setUp() {
        super.setUp()
        indexPath1 = NSIndexPath(forItem: 0, inSection: 0)
        indexPath2 = NSIndexPath(forItem: 1, inSection: 0)
    }

    func test__equality__equal_values_1() {
        XCTAssertEqual(Error.NoCellRegisteredAtIndex(indexPath1), Error.NoCellRegisteredAtIndex(indexPath1))
    }

    func test__equality__different_values_1() {
        XCTAssertNotEqual(Error.NoCellRegisteredAtIndex(indexPath1), Error.NoCellRegisteredAtIndex(indexPath2))
    }

    func test__equality__equal_values_2() {
        XCTAssertEqual(Error.InvalidCellRegisteredAtIndexWithIdentifier(indexPath1, "Hello World"), Error.InvalidCellRegisteredAtIndexWithIdentifier(indexPath1, "Hello World"))
    }

    func test__equality__different_values_2() {
        XCTAssertNotEqual(Error.InvalidCellRegisteredAtIndexWithIdentifier(indexPath1, "Hello"), Error.InvalidCellRegisteredAtIndexWithIdentifier(indexPath2, "Hello"))
        XCTAssertNotEqual(Error.InvalidCellRegisteredAtIndexWithIdentifier(indexPath1, "Hello"), Error.InvalidCellRegisteredAtIndexWithIdentifier(indexPath1, "World"))
    }

    func test__equality__different_case() {
        XCTAssertNotEqual(Error.NoCellRegisteredAtIndex(indexPath1), Error.InvalidCellRegisteredAtIndexWithIdentifier(indexPath2, "Hello"))
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
