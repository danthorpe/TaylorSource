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
    
    var dataSource: TypeUnderTest!

    override func setUp() {
        super.setUp()
        dataSource = TypeUnderTest(factory: TypeUnderTest.Factory(), items: [ "Hello", "World" ])
    }

    override func tearDown() {
        dataSource = nil
        super.tearDown()
    }
}

class DataSourceTypeDefaultImplementation: DataSourceTests {

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

