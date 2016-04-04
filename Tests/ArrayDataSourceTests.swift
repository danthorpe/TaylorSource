//
//  ArrayDataSourceTests.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 03/04/2016.
//  Copyright © 2016 Daniel Thorpe. All rights reserved.
//

import XCTest
@testable import TaylorSource

class ArrayDataSourceTests: XCTestCase {

    typealias TypeUnderTest = ArrayDataSource<TestableFactory>

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

extension ArrayDataSourceTests {
    
    func test__itemAtIndex__index_is_before_start_index__throws_error() {
        let index: Int = -10
        XCTAssertThrowsErrorEqual(try dataSource.itemAtIndex(index), DataSourceError.NoItemAtIndex(index))
    }

    func test__itemAtIndex__index_is_after_end_index__throws_error() {
        let index: Int = 10
        XCTAssertThrowsErrorEqual(try dataSource.itemAtIndex(index), DataSourceError.NoItemAtIndex(index))
    }

    func test__itemAtIndex__returns_item() {
        XCTAssertEqual(XCTAssertNoThrows(try dataSource.itemAtIndex(0)), "Hello")
    }
}



