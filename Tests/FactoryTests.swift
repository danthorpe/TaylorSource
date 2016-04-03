//
//  FactoryTests.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 11/03/2016.
//
//

import XCTest
@testable import TaylorSource

typealias TestableFactory = Factory<String, UITableViewCell, UITableViewHeaderFooterView, TestableTable, NSIndexPath, NSIndexPath>

class FactoryTests: XCTestCase {

    var factory: TestableFactory!
    var tableView: TestableFactory.ViewType!
    var identifier: String!
    var indexPath: TestableFactory.CellIndexType!
    var cell: TestableFactory.CellType!
    var supplementaryView: TestableFactory.SupplementaryViewType!
    var item: TestableFactory.ItemType!

    override func setUp() {
        super.setUp()
        factory = TestableFactory()
        tableView = TestableFactory.ViewType()
        identifier = "Test Cell Identifier"
        indexPath = NSIndexPath(forRow: 0, inSection: 0)
        cell = TestableFactory.CellType(style: .Default, reuseIdentifier: identifier)
        supplementaryView = TestableFactory.SupplementaryViewType(reuseIdentifier: identifier)
        item = "Hello World"
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

    func test__registerCell__classWithIdentifier__viewRegistersCellWithIdentifier() {
        factory.registerCell(.ClassWithIdentifier(TestableFactory.CellType.self, identifier), inView: tableView) { _, _, _ in }
        guard let (registeredClass, withIdentifier) = tableView.didRegisterClassWithIdentifier else {
            XCTFail("Table View did not register class with identifier"); return
        }
        XCTAssertNotNil(registeredClass)
        XCTAssertEqual(withIdentifier, identifier)
    }

    func test__registerCell__nibWithIdentifier__viewRegistersNibWithIdentifier() {
        factory.registerCell(.NibWithIdentifier(TestCell.nib, identifier), inView: tableView) { _, _, _ in }
        guard let (registeredNib, withIdentifier) = tableView.didRegisterNibWithIdentifier else {
            XCTFail("Table View did not register class with identifier"); return
        }
        XCTAssertNotNil(registeredNib)
        XCTAssertEqual(withIdentifier, identifier)
    }

    func test__registerCell() {
        var didExecuteConfiguration = false

        factory.registerCell(.ClassWithIdentifier(TestableFactory.CellType.self, identifier), inView: tableView) { cell, item, index in
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

class FactoryCellVendorTypeTests: FactoryTests {

    func test__cellForItem__no_cell_registered__throws_error() {
        XCTAssertThrowsError(try factory.cellForItem(item, inView: tableView, atIndex: indexPath), TestableFactory.Error.NoCellRegisteredAtIndex(indexPath))
    }

    func test__cellForItem__incorrect_cell_type_registered__throws_error() {
//        factory.registerCell(.ClassWithIdentifier(UITableViewCell.self, "Another Identifier"), inView: tableView) { _, _, _ in }
//        XCTAssertThrowsError(try factory.cellForItem(item, inView: tableView, atIndex: indexPath), TestableFactory.Error.InvalidCellRegisteredAtIndexWithIdentifier(indexPath, identifier))
    }

    func test__cellForItem__configureBlockReceivesCell() {
        factory.registerCell(.ClassWithIdentifier(TestableFactory.CellType.self, identifier), inView: tableView) { cell, item, index in
            cell.textLabel!.text = item
        }
        let cell = XCTAssertNoThrows(try factory.cellForItem(item, inView: tableView, atIndex: indexPath))
        XCTAssertEqual(cell.textLabel?.text ?? "Not Correct", item)
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
        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, identifier), kind: .Header, inView: tableView) { _, _ in }
        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, identifier), kind: .Footer, inView: tableView) { _, _ in }
        XCTAssertEqual(factory.views.count, 2)
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

class FactorySupplementaryTextRegistrarTypeTests: FactoryTests {

    func test__registerSupplementaryTextWithKind_multipleTimes() {
        factory.registerSupplementaryTextWithKind(.Header) { "Header text with index: \($0)" }
        factory.registerSupplementaryTextWithKind(.Footer) { "Footer text with index: \($0)" }
        XCTAssertEqual(factory.texts.count, 2)
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
