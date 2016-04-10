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
    
    var action: Edit.Action!
    
    func test__none() {
        action = Edit.Action(rawValue: .None)
        XCTAssertEqual(action, Edit.Action.None)
    }
    
    func test__insert() {
        action = Edit.Action(rawValue: .Insert)
        XCTAssertEqual(action, Edit.Action.Insert)
    }
    
    func test__delete() {
        action = Edit.Action(rawValue: .Delete)
        XCTAssertEqual(action, Edit.Action.Delete)
    }
}

