//
//  Created by Daniel Thorpe on 16/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import XCTest
import YapDatabase
import YapDatabaseExtensions
import TaylorSource
import Datasources
import Quick
import Nimble

class MapperSpec: QuickSpec {

    override func spec() {
        describe("Mapper") {

            var db: YapDatabase!
            var mapper: Mapper<Event>!

            beforeEach { metadata in
                db = createYapDatabase(__FILE__, suffix: metadata.example.name)
            }

            context("when database is empty") {
                beforeEach {
                    mapper = Mapper(database: db, configuration: events())
                }

                describe("initially") {
                    describe("the endIndex") {
                        it("is 0") {
                            expect(mapper.startIndex).to(equal(0))
                            expect(mapper.endIndex).to(equal(0))
                        }
                    }
                }
            }

            context("when database has one item") {

                var event: Event!

                beforeEach {
                    event = Event.create(color: .Red)
                    db.write(event)
                    mapper = Mapper(database: db, configuration: events())
                }

                describe("initially") {
                    describe("the endIndex") {
                        it("is 1") {
                            expect(mapper.startIndex).to(equal(0))
                            expect(mapper.endIndex).to(equal(1))
                        }
                    }
                }

                describe("lookup items by indexPath") {
                    describe("the first index path") {
                        it("is the item") {
                            expect(mapper.itemAtIndexPath(NSIndexPath.first)).to(equal(event))
                        }
                    }
                }

                describe("reverse lookup items") {
                    describe("the first item") {
                        it("is the first index path") {
                            expect(mapper.indexPathForKey(keyForPersistable(event), inCollection: Event.collection)).to(equal(NSIndexPath.first))
                        }
                    }
                }
            }
        }
    }
}

