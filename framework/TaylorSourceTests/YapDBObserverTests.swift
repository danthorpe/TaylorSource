//
//  Created by Daniel Thorpe on 16/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import XCTest

import YapDatabase
import YapDatabaseExtensions
import TaylorSource

func numberOfChangesInChangeset(changeset: YapDatabaseViewMappings.Changeset) -> Int {
    return changeset.sections.count + changeset.items.count
}

func numberOfSectionChangesOfType(type: YapDatabaseViewChangeType, inChangeset changeset: YapDatabaseViewMappings.Changeset) -> Int {
    return changeset.sections.filter { $0.type == type }.count
}

func numberOfItemChangesOfType(type: YapDatabaseViewChangeType, inChangeset changeset: YapDatabaseViewMappings.Changeset) -> Int {
    return changeset.items.filter { $0.type == type }.count
}

func validateChangeset(expectation: XCTestExpectation, validations: [YapDatabaseViewMappings.Changes]) -> YapDatabaseViewMappings.Changes {
    return { changeset in

        for validation in validations {
            validation(changeset)
        }
        expectation.fulfill()
    }
}

func validateChangesetHasSectionInsert(count: Int = 1) -> YapDatabaseViewMappings.Changes {
    return { changeset in
        XCTAssertEqual(numberOfSectionChangesOfType(.Insert, inChangeset: changeset), count)
    }
}

func validateChangesetHasRowInsert(count: Int = 1) -> YapDatabaseViewMappings.Changes {
    return { changeset in
        XCTAssertEqual(numberOfItemChangesOfType(.Insert, inChangeset: changeset), count)
    }
}

func createOneEvent(color: Event.Color = .Red) -> Event {
    return Event.create(color)
}

func createManyEvents(color: Event.Color = .Red) -> [Event] {
    return (0..<5).map { _ in createOneEvent(color) }
}

class ObserverTests: XCTestCase {

    var observer: Observer<Event>!
    let configuration: TaylorSource.Configuration<Event> = events(true)
}

extension ObserverTests {

    func testObserver_EmptyDatabase_EndIndexIsZero() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let observer = Observer(database: db, changes: { changeset in }, configuration: configuration)
        XCTAssertEqual(observer.startIndex, 0)
        XCTAssertEqual(observer.endIndex, 0)
    }

    func testObserver_WriteOneObject_ChangesetHasOneSectionInsert() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let connection = db.newConnection()
        let expectation = expectationWithDescription("Writing one object")

        observer = Observer(
            database: db,
            changes: validateChangeset(expectation, validations: [validateChangesetHasSectionInsert()]),
            configuration: configuration)

        connection.write(createOneEvent())
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testObserver_DatabaseWithOneRow_WriteOneObject_ChangesetHasOneRowInsert() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let connection = db.newConnection()
        let expectation = expectationWithDescription("Writing one object")

        connection.write(createOneEvent())

        observer = Observer(
            database: db,
            changes: validateChangeset(expectation, validations: [validateChangesetHasRowInsert()]),
            configuration: configuration)

        connection.write(createOneEvent())
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testObserver_WriteManyObjectToOneGroup_ChangesetHasOneSectionInsert() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let connection = db.newConnection()
        let expectation = expectationWithDescription("Writing many object")

        observer = Observer(
            database: db,
            changes: validateChangeset(expectation, validations: [validateChangesetHasSectionInsert()]),
            configuration: configuration)

        connection.write(createManyEvents())
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testObserver_WriteManyObjectToTwoGroups_ChangesetHasTwoSectionInsert() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let connection = db.newConnection()
        let expectation = expectationWithDescription("Writing many object to groups")

        observer = Observer(
            database: db,
            changes: validateChangeset(expectation, validations: [validateChangesetHasSectionInsert(2)]),
            configuration: configuration)

        var events = createManyEvents(.Red)
        events += createManyEvents(.Blue)

        connection.write(events)
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}


