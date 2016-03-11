//
//  FactoryTests.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 11/03/2016.
//
//

import XCTest
@testable import TaylorSource

typealias TestableFactory = Factory<String, UITableViewCell, UITableViewHeaderFooterView, UITableView, NSIndexPath, NSIndexPath>

class FactoryTests: XCTestCase {

    var factory: TestableFactory!
    
    override func setUp() {
        super.setUp()
        factory = TestableFactory()
    }
    
    override func tearDown() {
        factory = nil
        super.tearDown()
    }
}

class FactoryCellRegistrarTypeTests: FactoryTests {
    
    func test__defaultCellKey() {
        XCTAssertEqual(factory.defaultCellKey, "Default Cell Key")
    }
}

class FactorySupplementaryViewRegistrarTypeTests: FactoryTests {
    
    func test_defaultSupplementaryKey() {
        XCTAssertEqual(factory.defaultSupplementaryKey, "Default Suppplementary View Key")
    }
}

