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
import Datasources
import YapDatabaseExtensions
import TaylorSource
import Quick
import Nimble

class YapDBDatasourceTests: XCTestCase {

    typealias Factory = YapDBFactory<Event, UITableViewCell, UITableViewHeaderFooterView, StubbedTableView>
    typealias Datasource = YapDBDatasource<Factory>

    let configuration: TaylorSource.Configuration<Event> = events(byColor: true)
    let view = StubbedTableView()
    let factory = Factory()

    func datasourceWithDatabase(db: YapDatabase, changesValidator: YapDatabaseViewMappings.Changes? = .None) -> Datasource {
        if let changes = changesValidator {
            return Datasource(id: "test datasource", database: db, factory: factory, processChanges: changes, configuration: configuration)
        }
        return Datasource(id: "test datasource", database: db, factory: factory, processChanges: { changeset in }, configuration: configuration)
    }
}

extension YapDBDatasourceTests {

    func test_GivenEmptyDatabase_ThatHasCorrectSections() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        let datasource = datasourceWithDatabase(db)
        expect(datasource.numberOfSections).to(equal(0))
    }

    func test_GivenDatabaseWithOneRedEvent_ThatHasCorrectSections() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__) { database in
            database.write(createOneEvent())
        }
        let datasource = datasourceWithDatabase(db)
        expect(datasource.numberOfSections).to(equal(1))
        expect(datasource.numberOfItemsInSection(0)).to(equal(1))
    }

    func test_GivenDatabaseWithManyRedEvents_ThatHasCorrectSections() {
        var numberOfEvents: Int!
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__) { database in
            numberOfEvents = database.write(createManyEvents()).count
        }
        let datasource = datasourceWithDatabase(db)
        expect(datasource.numberOfSections).to(equal(1))
        expect(datasource.numberOfItemsInSection(0)).to(equal(numberOfEvents))
    }

    func test_GivenDatabaseWithManyRedAndManyBlueEvents_ThatHasCorrectSections() {
        var numberOfRedEvents: Int!
        var numberOfBlueEvents: Int!
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__) { database in
            numberOfRedEvents = database.write(createManyEvents()).count
            numberOfBlueEvents = database.write(createManyEvents(color: .Blue)).count
        }
        let datasource = datasourceWithDatabase(db)
        expect(datasource.numberOfSections).to(equal(2))
        expect(datasource.numberOfItemsInSection(0)).to(equal(numberOfRedEvents))
        expect(datasource.numberOfItemsInSection(1)).to(equal(numberOfBlueEvents))
    }

    func test_GivenStaticDatasource_WhenAccessingItemsAtANegativeIndex_ThatResultIsNone() {
        var numberOfEvents: Int!
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__) { database in
            numberOfEvents = database.write(createManyEvents()).count
        }
        let datasource = datasourceWithDatabase(db)
        expect(datasource.itemAtIndexPath(NSIndexPath(forRow: numberOfEvents * -1, inSection: 0))).to(beNil())
    }

    func test_GivenStaticDatasource_WhenAccessingItemsGreaterThanMaxIndex_ThatResultIsNone() {
        var numberOfEvents: Int!
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__) { database in
            numberOfEvents = database.write(createManyEvents()).count
        }
        let datasource = datasourceWithDatabase(db)
        expect(datasource.itemAtIndexPath(NSIndexPath(forRow: numberOfEvents * 2, inSection: 0))).to(beNil())
    }

    func test_GivenStaticDatasource_WhenAccessingItems_ThatCorrectItemIsReturned() {
        var events: [Event]!
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__) { database in
            events = database.write(createManyEvents())
        }
        let datasource = datasourceWithDatabase(db)
        expect(datasource.itemAtIndexPath(NSIndexPath.first)).to(equal(events[0]))
    }
}

