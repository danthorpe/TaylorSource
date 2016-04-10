//
//  DataSourceTests.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 11/03/2016.
//
//

import XCTest
@testable import TaylorSource

class DataSourceTests: XCTestCase {
    
    typealias DataSource = BasicDataSource<TestableFactory>
    typealias Cell = DataSource.Factory.Cell
    typealias Item = DataSource.Factory.Item
    typealias Index = DataSource.Factory.CellIndex
    typealias SupplementaryView = DataSource.Factory.SupplementaryView
    typealias SupplementaryIndex = DataSource.Factory.SupplementaryIndex

    var tableView: TestableTable!
    var factory: DataSource.Factory!
    var dataSource: DataSource!

    override func setUp() {
        super.setUp()
        tableView = TestableTable()
        factory = DataSource.Factory()
        dataSource = DataSource(factory: factory, items: [ "Hello", "World" ])
    }

    override func tearDown() {
        tableView = nil
        factory = nil
        dataSource = nil
        super.tearDown()
    }
}

class DefaultImplementationMethodsDataSourceTests: DataSourceTests {

    func test__numberOfSections() {
        XCTAssertEqual(dataSource.numberOfSections, 1)
    }

    func test__totalNumberOfItems() {
        XCTAssertEqual(dataSource.totalNumberOfItems, 2)
    }

    func test__startIndex() {
        XCTAssertEqual(dataSource.startIndex, 0)
    }

    func test__endIndex() {
        XCTAssertEqual(dataSource.endIndex, 2)
    }
}

