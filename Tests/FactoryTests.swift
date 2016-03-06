//
//  FactoryTests.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 20/02/2016.
//
//

import XCTest
import UIKit
@testable import TaylorSource

class SupplementaryElementKindTests: XCTestCase {

    var kind: SupplementaryElementKind!

    func test_init_header() {
        kind = SupplementaryElementKind(UICollectionElementKindSectionHeader)
        XCTAssertEqual(kind, SupplementaryElementKind.Header)
    }

    func test_init_footer() {
        kind = SupplementaryElementKind(UICollectionElementKindSectionFooter)
        XCTAssertEqual(kind, SupplementaryElementKind.Footer)
    }

    func test_init_custom() {
        kind = SupplementaryElementKind("A Custom Kind")
        XCTAssertEqual(kind, SupplementaryElementKind.Custom("A Custom Kind"))
    }

    func test_description_header() {
        kind = .Header
        XCTAssertEqual(kind.description, UICollectionElementKindSectionHeader)
    }

    func test_description_footer() {
        kind = .Footer
        XCTAssertEqual(kind.description, UICollectionElementKindSectionFooter)
    }

    func test_description_custom() {
        kind = .Custom("A Custom Kind")
        XCTAssertEqual(kind.description, "A Custom Kind")
    }

    func test_equality_header_and_header_equal() {
        XCTAssertEqual(SupplementaryElementKind.Header, SupplementaryElementKind.Header)
    }

    func test_equality_footer_and_footer_equal() {
        XCTAssertEqual(SupplementaryElementKind.Footer, SupplementaryElementKind.Footer)
    }

    func test_equality_custom_and_custom_equal() {
        XCTAssertEqual(SupplementaryElementKind.Custom("A Custom Kind"), SupplementaryElementKind.Custom("A Custom Kind"))
    }

    func test_equality_header_and_footer_not_equal() {
        XCTAssertNotEqual(SupplementaryElementKind.Header, SupplementaryElementKind.Footer)
    }

    func test_equality_header_and_custom_not_equal() {
        XCTAssertNotEqual(SupplementaryElementKind.Header, SupplementaryElementKind.Custom("A Custom Kind"))
    }

    func test_equality_footer_and_custom_not_equal() {
        XCTAssertNotEqual(SupplementaryElementKind.Footer, SupplementaryElementKind.Custom("A Custom Kind"))
    }

    func test_equality_custom_and_custom_not_equal() {
        XCTAssertNotEqual(SupplementaryElementKind.Custom("A Different Custom Kind"), SupplementaryElementKind.Custom("A Custom Kind"))
    }
}

protocol TestableCellBasedViewType: CellBasedViewType {
    init()
}

class FactoryTestHarness<Item, Cell, SupplementaryView, View: TestableCellBasedViewType> {

    typealias ViewUnderTest = View
    typealias TypeUnderTest = Factory<Item, Cell, SupplementaryView, View, NSIndexPath, NSIndexPath>

    var factory: TypeUnderTest! = nil
    var view: ViewUnderTest! = nil
    var descriptor: ReusableViewDescriptor! = nil

    func setUp() {
        view = ViewUnderTest()
        factory = TypeUnderTest()
        descriptor = .DynamicWithIdentifier("An Identifier")
    }

    func tearDown() {
        factory = nil
    }
}

class FactoryRegistrationTests: XCTestCase {

    typealias Harness = FactoryTestHarness<String, String, String, TestableCellBasedView<String, String>>

    var harness: Harness!

    var factory: Harness.TypeUnderTest {
        get { return harness.factory }
        set { harness.factory = newValue }
    }

    var view: Harness.ViewUnderTest {
        return harness.view
    }

    var descriptor: ReusableViewDescriptor {
        get { return harness.descriptor }
        set { harness.descriptor = newValue }
    }

    override func setUp() {
        super.setUp()
        harness = Harness()
        harness.setUp()
    }
    
    override func tearDown() {
        harness.tearDown()
        super.tearDown()
    }
}

class FactoryCellRegistrarTests: FactoryRegistrationTests {

    func test_register__sets_tuple_in_cell_storage() {
        factory.registerCell(descriptor, inView: view) { _, _, _ in }
        XCTAssertEqual(factory.cells.count, 1)
        XCTAssertNotNil(factory.cells[factory.defaultCellKey])
    }

    func test_register_with_key__sets_tuple_in_cell_storage() {
        factory.registerCell(descriptor, inView: view, withKey: "A Key") { _, _, _ in }
        XCTAssertEqual(factory.cells.count, 1)
        XCTAssertNotNil(factory.cells["A Key"])
        XCTAssertNil(factory.cells["Wrong Key"])
    }

    func test_register_nib_cell__sets_tuple_in_cell_storage() {
        descriptor = .NibWithIdentifier(UINib(), "An Identifier")
        factory.registerCell(descriptor, inView: view) { _, _, _ in }
        let (_, identifier) = view.didRegisterNibWithIdentifier ?? (UINib(), "Wrong Identifier")
        XCTAssertEqual(identifier, "An Identifier")
    }

    func test_register_class_cell__sets_tuple_in_cell_storage() {
        descriptor = .ClassWithIdentifier(UITableViewCell.self, "An Identifier")
        factory.registerCell(descriptor, inView: view) { _, _, _ in }
        let (_, identifier) = view.didRegisterClassWithIdentifier ?? (UICollectionViewCell.self, "Wrong Identifier")
        XCTAssertEqual(identifier, "An Identifier")
    }
}

class FactorySupplementaryViewRegistrarTests: FactoryRegistrationTests {

    func test_register__sets_tuple_in_cell_storage() {
        let kind: SupplementaryElementKind = .Custom("My Custom Kind")
        factory.registerSupplementaryView(descriptor, kind: kind, inView: view) { _, _ in }
        let index = factory.defaultSupplementaryIndexForKind(kind)
        XCTAssertEqual(factory.views.count, 1)
        XCTAssertNotNil(factory.views[index])
    }

    func test_register_header__sets_tuple_in_cell_storage() {
        factory.registerSupplementaryView(descriptor, kind: .Header, inView: view) { _, _ in }
        XCTAssertEqual(factory.views.count, 1)
        XCTAssertNotNil(factory.views[factory.defaultSupplementaryIndexForKind(.Header)])
        XCTAssertNil(factory.views[factory.defaultSupplementaryIndexForKind(.Footer)])
    }

    func test_register_footer__sets_tuple_in_cell_storage() {
        factory.registerSupplementaryView(descriptor, kind: .Footer, inView: view) { _, _ in }
        XCTAssertEqual(factory.views.count, 1)
        XCTAssertNotNil(factory.views[factory.defaultSupplementaryIndexForKind(.Footer)])
        XCTAssertNil(factory.views[factory.defaultSupplementaryIndexForKind(.Header)])
    }

    func test_register_with_key__sets_tuple_in_cell_storage() {
        let kind: SupplementaryElementKind = .Custom("My Custom Kind")
        factory.registerSupplementaryView(descriptor, kind: kind, inView: view, withKey: "A Key") { _, _ in }
        let index = SupplementaryElementIndex(kind: kind, key: "A Key")
        XCTAssertEqual(factory.views.count, 1)
        XCTAssertNotNil(factory.views[index])
    }

    func test_register_nib_cell__sets_tuple_in_cell_storage() {
        descriptor = .NibWithIdentifier(UINib(), "An Identifier")
        factory.registerSupplementaryView(descriptor, kind: .Header, inView: view) { _, _ in }
        let (_, kind, identifier) = view.didRegisterNibForKindWithIdentifier ?? (UINib(), SupplementaryElementKind.Footer, "Wrong Identifier")
        XCTAssertEqual(kind, SupplementaryElementKind.Header)
        XCTAssertEqual(identifier, "An Identifier")
    }

    func test_register_class_cell__sets_tuple_in_cell_storage() {
        descriptor = .ClassWithIdentifier(UITableViewCell.self, "An Identifier")
        factory.registerSupplementaryView(descriptor, kind: .Footer, inView: view) { _, _ in }
        let (_, kind, identifier) = view.didRegisterClassForKindWithIdentifier ?? (UICollectionViewCell.self, SupplementaryElementKind.Header, "Wrong Identifier")
        XCTAssertEqual(kind, SupplementaryElementKind.Footer)
        XCTAssertEqual(identifier, "An Identifier")
    }
}

class FactorySupplementaryTextRegistrarTests: FactoryRegistrationTests {

    func test_register_custom__sets_cell_storage() {
        let kind: SupplementaryElementKind = .Custom("My Custom Kind")
        factory.registerSupplementaryTextWithKind(kind) { _ in "Some Text" }
        XCTAssertEqual(factory.texts.count, 1)
        XCTAssertNotNil(factory.texts[kind])
    }

    func test_register_header__sets_cell_storage() {
        factory.registerSupplementaryTextWithKind(.Header) { _ in "Some Text" }
        XCTAssertEqual(factory.texts.count, 1)
        XCTAssertNotNil(factory.texts[.Header])
    }

    func test_register_footer__sets_cell_storage() {
        factory.registerSupplementaryTextWithKind(.Footer) { _ in "Some Text" }
        XCTAssertEqual(factory.texts.count, 1)
        XCTAssertNotNil(factory.texts[.Footer])
    }

    func test__register__stores_configuration() {
        factory.registerSupplementaryTextWithKind(.Footer) { _ in "Some Text" }
        guard let configure = factory.texts[.Footer] else { XCTFail("Configure block not stored."); return }
        let text = configure(index: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(text, "Some Text")
    }
}

extension UITableView: TestableCellBasedViewType { }

class FactoryVendorTests: XCTestCase {

    typealias Harness = FactoryTestHarness<String, UITableViewCell, UITableViewHeaderFooterView, UITableView>

    var harness: Harness!

    var factory: Harness.TypeUnderTest {
        get { return harness.factory }
        set { harness.factory = newValue }
    }

    var view: Harness.TypeUnderTest.ViewType {
        return harness.view
    }

    var descriptor: ReusableViewDescriptor {
        get { return harness.descriptor }
        set { harness.descriptor = newValue }
    }

    override func setUp() {
        super.setUp()
        harness = Harness()
        harness.setUp()
    }

    override func tearDown() {
        harness.tearDown()
        super.tearDown()
    }
}

class FactoryCellVendorTests: FactoryVendorTests {

    override func setUp() {
        super.setUp()
        descriptor = .ClassWithIdentifier(UITableViewCell.self, "An Identifier")
    }

    func test_configued_cell_is_dequeued() {
        factory.registerCell(descriptor, inView: view) { cell, item, index in
            cell.textLabel?.text = item
        }
        do {
            let cell = try factory.cellForItem("Hello World", inView: view, atIndex: NSIndexPath(forRow: 0, inSection: 0))
            XCTAssertEqual(cell.textLabel?.text ?? "Goodbye World", "Hello World")
        }
        catch { XCTFail("Caught unexpected error: \(error)") }
    }
}
