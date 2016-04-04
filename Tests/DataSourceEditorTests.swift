//
//  DataSourceEditorTests.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 04/04/2016.
//  Copyright © 2016 Daniel Thorpe. All rights reserved.
//

import XCTest
@testable import TaylorSource

class DataSourceEditActionTests: XCTestCase {
    
    var action: DataSourceEditAction!
    
    func test__none() {
        action = DataSourceEditAction(rawValue: .None)
        XCTAssertEqual(action, DataSourceEditAction.None)
    }
    
    func test__insert() {
        action = DataSourceEditAction(rawValue: .Insert)
        XCTAssertEqual(action, DataSourceEditAction.Insert)
    }
    
    func test__delete() {
        action = DataSourceEditAction(rawValue: .Delete)
        XCTAssertEqual(action, DataSourceEditAction.Delete)
    }
}

