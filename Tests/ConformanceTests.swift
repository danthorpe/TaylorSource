//
//  ConformanceTests.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 10/04/2016.
//  Copyright © 2016 Daniel Thorpe. All rights reserved.
//

import XCTest
@testable import TaylorSource

class ConformanceTests: XCTestCase {

    func test__indexPath__indexPath_property_returns_self() {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        XCTAssertEqual(indexPath, indexPath.indexPath)
    }

    func test__indexPath__indexInView_property_returns_self() {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        XCTAssertEqual(indexPath, indexPath.indexInView)
    }

    func test__index__indexInView_property_returns_self() {
        let index: Int = 0
        XCTAssertEqual(index, index.indexInView)
    }
}
