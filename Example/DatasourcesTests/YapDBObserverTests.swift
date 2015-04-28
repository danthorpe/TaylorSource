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

        println("Number of changes: \(numberOfChangesInChangeset(changeset))")
        println("Number of section inserts: \(numberOfSectionChangesOfType(.Insert, inChangeset: changeset))")
        println("Number of section deletes: \(numberOfSectionChangesOfType(.Delete, inChangeset: changeset))")
        println("Number of item inserts: \(numberOfItemChangesOfType(.Insert, inChangeset: changeset))")
        println("Number of item deletes: \(numberOfItemChangesOfType(.Delete, inChangeset: changeset))")
        println("Number of item moves: \(numberOfItemChangesOfType(.Move, inChangeset: changeset))")
        println("Number of item updates: \(numberOfItemChangesOfType(.Update, inChangeset: changeset))")

        for validation in validations {
            validation(changeset)
        }
        expectation.fulfill()
    }
}

func validateChangesetHasSectionInsert(count: Int = 1) -> YapDatabaseViewMappings.Changes {
    return { changeset in
        println("changeset: \(changeset)")
        XCTAssertEqual(count, numberOfSectionChangesOfType(.Insert, inChangeset: changeset), "Changeset did not have the correct number of section insets")
    }
}

class ObserverTests: XCTestCase {

    let configuration: Configuration<Event> = events(byColor: true)

    func createOneEvent(color: Event.Color = .Red) -> Event {
        return Event.create(color: color)
    }

    func createManyEvents(color: Event.Color = .Red) -> [Event] {
        return map(0..<5) { _ in self.createOneEvent(color: color) }
    }
}

extension ObserverTests {

    func testObserver_EmptyDatabase_EndIndexIsZero() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        let observer = Observer(database: db, changes: { changeset in }, configuration: configuration)
        XCTAssertEqual(observer.startIndex, 0, "The start index should be zero")
        XCTAssertEqual(observer.endIndex, 0, "The end index should be zero")
    }

    func testObserver_WriteOneObject_ChangesetHasOneSectionInsert() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        let connection = db.newConnection()
        let expectation = expectationWithDescription("Writing one object")

        let observer = Observer(
            database: db,
            changes: validateChangeset(expectation, [validateChangesetHasSectionInsert()]),
            configuration: configuration)

        connection.write(createOneEvent())
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testObserver_WriteManyObjectToOneGroup_ChangesetHasOneSectionInsert() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        let connection = db.newConnection()
        let expectation = expectationWithDescription("Writing many object")

        let observer = Observer(
            database: db,
            changes: validateChangeset(expectation, [validateChangesetHasSectionInsert()]),
            configuration: configuration)

        connection.write(createManyEvents())
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testObserver_WriteManyObjectToTwoGroups_ChangesetHasTwoSectionInsert() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        let connection = db.newConnection()
        let expectation = expectationWithDescription("Writing many object to groups")

        let observer = Observer(
            database: db,
            changes: validateChangeset(expectation, [validateChangesetHasSectionInsert(count: 2)]),
            configuration: configuration)

        var events = createManyEvents(color: .Red)
        events += createManyEvents(color: .Blue)

        connection.write(events)
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}




