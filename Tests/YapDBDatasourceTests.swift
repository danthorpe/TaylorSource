//
//  YapDBDatasourceTests.swift
//  Datasources
//
//  Created by Daniel Thorpe on 08/05/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import XCTest

import YapDatabase
import YapDatabaseExtensions
import TaylorSource

class YapDBDatasourceTests: XCTestCase {

    typealias Factory = YapDBFactory<Event, UITableViewCell, UITableViewHeaderFooterView, StubbedTableView>
    typealias Datasource = YapDBDatasource<Factory>

    let configuration: TaylorSource.Configuration<Event> = events(true)
    let view = StubbedTableView()
    let factory = Factory()

    var someEvents: [Event]!
    var numberOfEvents: Int!

    override func setUp() {
        super.setUp()
        someEvents = createManyEvents()
        numberOfEvents = someEvents.count
    }

    func datasourceWithDatabase(db: YapDatabase, changesValidator: YapDatabaseViewMappings.Changes? = .None) -> Datasource {
        if let changes = changesValidator {
            return Datasource(id: "test datasource", database: db, factory: factory, processChanges: changes, configuration: configuration)
        }
        return Datasource(id: "test datasource", database: db, factory: factory, processChanges: { changeset in }, configuration: configuration)
    }
}

extension YapDBDatasourceTests {

    func test_GivenEmptyDatabase_ThatHasCorrectSections() {
        let db = YapDB.testDatabase()
        let datasource = datasourceWithDatabase(db)
        XCTAssertEqual(datasource.numberOfSections, 0)
    }

    func test_GivenDatabaseWithOneRedEvent_ThatHasCorrectSections() {
        let db = YapDB.testDatabase() { database in
            database.newConnection().write(createOneEvent())
        }
        let datasource = datasourceWithDatabase(db)
        XCTAssertEqual(datasource.numberOfSections, 1)
        XCTAssertEqual(datasource.numberOfItemsInSection(0), 1)
    }

    func test_GivenDatabaseWithManyRedEvents_ThatHasCorrectSections() {
        let db = YapDB.testDatabase() { database in
            database.newConnection().write(self.someEvents)
        }
        let datasource = datasourceWithDatabase(db)
        XCTAssertEqual(datasource.numberOfSections, 1)
        XCTAssertEqual(datasource.numberOfItemsInSection(0), numberOfEvents)
    }

    func test_GivenDatabaseWithManyRedAndManyBlueEvents_ThatHasCorrectSections() {
        let redEvents = createManyEvents()
        let numberOfRedEvents = redEvents.count
        let blueEvents = createManyEvents(.Blue)
        let numberOfBlueEvents = blueEvents.count
        let db = YapDB.testDatabase() { database in
            database.newConnection().write { transaction in
                transaction.write(redEvents)
                transaction.write(blueEvents)
            }
        }
        let datasource = datasourceWithDatabase(db)
        XCTAssertEqual(datasource.numberOfSections, 2)
        XCTAssertEqual(datasource.numberOfItemsInSection(0), numberOfRedEvents)
        XCTAssertEqual(datasource.numberOfItemsInSection(1), numberOfBlueEvents)
    }

    func test_GivenStaticDatasource_WhenAccessingItemsAtANegativeIndex_ThatResultIsNone() {
        let db = YapDB.testDatabase() { database in
            database.newConnection().write(self.someEvents)
        }
        let datasource = datasourceWithDatabase(db)
        XCTAssertTrue(datasource.itemAtIndexPath(NSIndexPath(forRow: numberOfEvents * -1, inSection: 0)) == nil)
    }

    func test_GivenStaticDatasource_WhenAccessingItemsGreaterThanMaxIndex_ThatResultIsNone() {
        let db = YapDB.testDatabase() { database in
            database.newConnection().write(self.someEvents)
        }
        let datasource = datasourceWithDatabase(db)
        XCTAssertTrue(datasource.itemAtIndexPath(NSIndexPath(forRow: numberOfEvents * -1, inSection: 0)) == nil)
    }

    func test_GivenStaticDatasource_WhenAccessingItems_ThatCorrectItemIsReturned() {
        let db = YapDB.testDatabase() { database in
            database.newConnection().write(self.someEvents)
        }
        let datasource = datasourceWithDatabase(db)
        XCTAssertEqual(datasource.itemAtIndexPath(NSIndexPath.first)!, someEvents[0])
    }
}

