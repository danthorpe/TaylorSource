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

    var cellIndex: NSIndexPath!
    var supplementaryIndex: Int!

    override func setUp() {
        super.setUp()
        cellIndex = NSIndexPath(forRow: 0, inSection: 0)
        supplementaryIndex = 0
    }
}

extension CellDataSourceTests {

    func test__itemAtIndex__returns_item() {
        let item: DataSource.Factory.Item = XCTAssertNoThrows(try dataSource.itemAtIndex(cellIndex))
        XCTAssertEqual(item, "Hello")
    }

    func test__itemAtIndex__transforms_data_item() {
        var didTransformItem: DataSource.Item? = .None
        dataSource.transformItemToCellItem = { item in
            didTransformItem = item
            return item
        }

        let _: DataSource.Factory.Item = XCTAssertNoThrows(try dataSource.itemAtIndex(cellIndex))
        XCTAssertEqual(didTransformItem ?? "Not Hello", "Hello")
    }

    func test__itemAtIndex__throws_error_in_transform() {
        let error = TestError()
        dataSource.transformItemToCellItem = { _ in throw error }
        XCTAssertThrowsError(try dataSource.cellForItemInView(tableView, atIndex: cellIndex), error)
    }
}

extension CellDataSourceTests {

    func test__cellForItemInViewAtIndex__returns_configured_cell() {
        cellIndex = NSIndexPath(forRow: 1, inSection: 0)
        var didConfigureCellWithItemAtIndex: (Cell, Item, Index)? = .None

        factory.registerCell(.ClassWithIdentifier(UITableViewCell.self, "cell identifier"), inView: tableView) { cell, item, index in
            didConfigureCellWithItemAtIndex = (cell, item, index)
        }

        let cell = XCTAssertNoThrows(try dataSource.cellForItemInView(tableView, atIndex: cellIndex))

        XCTAssertNotNil(cell)

        guard let (configuredCell, item, configuredIndexPath) = didConfigureCellWithItemAtIndex else {
            XCTFail("Did not configure cell."); return
        }

        XCTAssertEqual(cell, configuredCell)
        XCTAssertEqual(item, "World")
        XCTAssertEqual(configuredIndexPath, cellIndex)
    }

    func test__cellForItemInViewAtIndex__invalid_index__throws_error() {
        cellIndex = NSIndexPath(forRow: 10, inSection: 0)
        XCTAssertThrowsError(try dataSource.cellForItemInView(tableView, atIndex: cellIndex), DataSourceError.NoItemAtIndex(cellIndex))
    }
}

extension CellDataSourceTests {

    func test__supplementaryViewForElementKindInViewAtIndex__returns_supplementary_view() {
        var didConfigureSupplementaryViewAtIndex: (SupplementaryView, SupplementaryIndex)? = .None
        factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "supplementary view identififer"), kind: .Header, inView: tableView) { supplementaryView, index in
            didConfigureSupplementaryViewAtIndex = (supplementaryView, index)
        }

        guard let view = dataSource.supplementaryViewForElementKind(.Header, inView: tableView, atIndex: supplementaryIndex) else {
            XCTFail("Supplementary view not returned"); return
        }

        guard let (configuredView, configuredIndex) = didConfigureSupplementaryViewAtIndex else {
            XCTFail("Supplementary view not configured"); return
        }

        XCTAssertEqual(view, configuredView)
        XCTAssertEqual(supplementaryIndex, configuredIndex)
    }

    func test__supplementaryViewForElementKindInViewAtIndex__returns_nil_if_not_registered() {
        XCTAssertNil(dataSource.supplementaryViewForElementKind(.Header, inView: tableView, atIndex: supplementaryIndex))
    }
}

extension CellDataSourceTests {

    func test__supplementaryTextForElementKindInViewAtIndex__returns_supplementary_text() {
        factory.registerSupplementaryTextWithKind(.Footer) { "Footer Text: \($0)" }

        guard let text = dataSource.supplementaryTextForElementKind(.Footer, inView: tableView, atIndex: supplementaryIndex) else {
            XCTFail("Supplementary text not returned"); return
        }

        XCTAssertEqual(text, "Footer Text: 0")
    }

    func test__supplementaryTextForElementKindInViewAtIndex__returns_nil_if_not_registered() {
        XCTAssertNil(dataSource.supplementaryTextForElementKind(.Footer, inView: tableView, atIndex: supplementaryIndex))
    }
}



