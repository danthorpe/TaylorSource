//
//  CellDataSourceTests.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 10/04/2016.
//  Copyright © 2016 Daniel Thorpe. All rights reserved.
//

import XCTest
@testable import TaylorSource

class CellDataSourceTests: DataSourceTests {

    var indexPath: NSIndexPath!

    override func setUp() {
        super.setUp()
        indexPath = NSIndexPath(forRow: 0, inSection: 0)
    }
}

extension CellDataSourceTests {

    func test__itemAtIndex__returns_item() {
        let item: TypeUnderTest.Factory.Item = XCTAssertNoThrows(try dataSource.itemAtIndex(indexPath))
        XCTAssertEqual(item, "Hello")
    }

    func test__itemAtIndex__transforms_data_item() {
        var didTransformItem: TypeUnderTest.Item? = .None
        dataSource.transformItemToCellItem = { item in
            didTransformItem = item
            return item
        }

        let _: TypeUnderTest.Factory.Item = XCTAssertNoThrows(try dataSource.itemAtIndex(indexPath))
        XCTAssertEqual(didTransformItem ?? "Not Hello", "Hello")
    }

    func test__itemAtIndex__throws_error_in_transform() {
        let error = TestError()
        dataSource.transformItemToCellItem = { _ in throw error }
        XCTAssertThrowsError(try dataSource.cellForItemInView(tableView, atIndex: indexPath), error)
    }
}

extension CellDataSourceTests {

    func test__cellForItemInViewAtIndex__returns_configured_cell() {
        indexPath = NSIndexPath(forRow: 1, inSection: 0)
        var didConfigureCellWithItemAtIndex: (Cell, Item, Index)? = .None

        factory.registerCell(.ClassWithIdentifier(UITableViewCell.self, "cell identifier"), inView: tableView) { cell, item, index in
            didConfigureCellWithItemAtIndex = (cell, item, index)
        }

        let cell = XCTAssertNoThrows(try dataSource.cellForItemInView(tableView, atIndex: indexPath))

        XCTAssertNotNil(cell)

        guard let (configuredCell, item, configuredIndexPath) = didConfigureCellWithItemAtIndex else {
            XCTFail("Did not configure cell."); return
        }

        XCTAssertEqual(cell, configuredCell)
        XCTAssertEqual(item, "World")
        XCTAssertEqual(configuredIndexPath, indexPath)
    }

    func test__cellForItemInViewAtIndex__invalid_index__throws_error() {
        indexPath = NSIndexPath(forRow: 10, inSection: 0)
        XCTAssertThrowsError(try dataSource.cellForItemInView(tableView, atIndex: indexPath), DataSourceError.NoItemAtIndex(indexPath))
    }
}

extension CellDataSourceTests {

    func test__supplementaryViewForElementKindInViewAtIndex__returns_supplementary_view() {
        var didConfigureSupplementaryViewAtIndex: (SupplementaryView, SupplementaryIndex)? = .None
        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "supplementary view identififer"), kind: .Header, inView: tableView) { supplementaryView, index in
            didConfigureSupplementaryViewAtIndex = (supplementaryView, index)
        }

        guard let view = dataSource.supplementaryViewForElementKind(.Header, inView: tableView, atIndex: indexPath) else {
            XCTFail("Supplementary view not returned"); return
        }

        guard let (configuredView, configuredIndex) = didConfigureSupplementaryViewAtIndex else {
            XCTFail("Supplementary view not configured"); return
        }

        XCTAssertEqual(view, configuredView)
        XCTAssertEqual(indexPath, configuredIndex)
    }

    func test__supplementaryViewForElementKindInViewAtIndex__returns_nil_if_not_registered() {
        XCTAssertNil(dataSource.supplementaryViewForElementKind(.Header, inView: tableView, atIndex: indexPath))
    }
}

extension CellDataSourceTests {

    func test__supplementaryTextForElementKindInViewAtIndex__returns_supplementary_text() {
        factory.registerSupplementaryTextWithKind(.Footer) { "Footer Text: \($0.section)" }

        guard let text = dataSource.supplementaryTextForElementKind(.Footer, inView: tableView, atIndex: indexPath) else {
            XCTFail("Supplementary text not returned"); return
        }

        XCTAssertEqual(text, "Footer Text: 0")
    }

    func test__supplementaryTextForElementKindInViewAtIndex__returns_nil_if_not_registered() {
        XCTAssertNil(dataSource.supplementaryTextForElementKind(.Footer, inView: tableView, atIndex: indexPath))
    }
}



