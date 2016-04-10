//
//  ArrayDataSourceTests.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 03/04/2016.
//  Copyright © 2016 Daniel Thorpe. All rights reserved.
//

import XCTest
@testable import TaylorSource

class ArrayDataSourceTests: DataSourceTests { }

extension ArrayDataSourceTests {
    
    func test__itemAtIndex__index_is_before_start_index__throws_error() {
        let index: Int = -10
        XCTAssertThrowsError(try dataSource.itemAtIndex(index), DataSourceError.NoItemAtIndex(index))
    }

    func test__itemAtIndex__index_is_after_end_index__throws_error() {
        let index: Int = 10
        XCTAssertThrowsError(try dataSource.itemAtIndex(index), DataSourceError.NoItemAtIndex(index))
    }

    func test__itemAtIndex__returns_item() {
        XCTAssertEqual(XCTAssertNoThrows(try dataSource.itemAtIndex(0)), "Hello")
    }
}

extension ArrayDataSourceTests {

    func test__subscript() {
        XCTAssertEqual(dataSource[0], "Hello")
        XCTAssertEqual(dataSource[1], "World")
    }
}

extension ArrayDataSourceTests {

    func test__generator() {
        for (i, item) in dataSource.enumerate() {
            switch i {
            case 0:
                XCTAssertEqual(item, "Hello")
            case 1:
                XCTAssertEqual(item, "World")
            default:
                XCTFail("Unexpected item: \(item)")
            }
        }
    }
}

extension ArrayDataSourceTests {

    func test__cellForItemInView__returns_configured_cell() {
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
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
}



