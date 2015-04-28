//
//  Created by Daniel Thorpe on 16/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import XCTest
import YapDatabase
import Datasources
import YapDatabaseExtensions
import TaylorSource

class MapperTests: XCTestCase {
    let event = Event.create(color: .Red)
    let configuration: Configuration<Event> = events()
}

extension MapperTests {

    func testMapper_EmptyDatabase_EndIndexIsZero() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        let mapper = Mapper(database: db, configuration: configuration)
        XCTAssertEqual(mapper.startIndex, 0, "The start index should be zero")
        XCTAssertEqual(mapper.endIndex, 0, "The end index should be zero")
    }

    func testMapper_NonEmptyDatabase_EndIndexIsCorrect() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        db.write(event)
        let mapper = Mapper(database: db, configuration: configuration)
        XCTAssertEqual(mapper.startIndex, 0, "The start index should be zero")
        XCTAssertEqual(mapper.endIndex, 1, "The end index should be zero")
    }

    func testMapper_NonEmptyDatabase_AbleToAccessByIndexPath() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        db.write(event)
        let mapper = Mapper(database: db, configuration: configuration)
        XCTAssertTrue(mapper.itemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) != nil, "Should be able to access items by index path.")
    }

    func testMapper_NonEmptyDatabase_AbleToReverseLookupIndexPathFromKey() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        db.write(event)
        let mapper = Mapper(database: db, configuration: configuration)
        let indexPath = mapper.indexPathForKey(keyForPersistable(event), inCollection: Event.collection)
        XCTAssertNotNil(indexPath, "Index Path should have been found.")
        XCTAssertEqual(NSIndexPath(forRow: 0, inSection: 0), indexPath!, "Index path should be the first one.")
    }
}

