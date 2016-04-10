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
    
    typealias TypeUnderTest = BasicDataSource<TestableFactory>
    typealias Cell = TypeUnderTest.Factory.Cell
    typealias Item = TypeUnderTest.Factory.Item
    typealias Index = TypeUnderTest.Factory.CellIndex
    typealias SupplementaryView = TypeUnderTest.Factory.SupplementaryView
    typealias SupplementaryIndex = TypeUnderTest.Factory.SupplementaryIndex

    var tableView: TestableTable!
    var factory: TypeUnderTest.Factory!
    var dataSource: TypeUnderTest!

    override func setUp() {
        super.setUp()
        tableView = TestableTable()
        factory = TypeUnderTest.Factory()
        dataSource = TypeUnderTest(factory: factory, items: [ "Hello", "World" ])
    }

    override func tearDown() {
        tableView = nil
        factory = nil
        dataSource = nil
        super.tearDown()
    }
}

extension DataSourceTests {

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

