//
//  Created by Daniel Thorpe on 16/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import XCTest
import Datasources
import TaylorSource

class StaticDatasourceTests: XCTestCase {

    typealias Factory = BasicFactory<Event, UITableViewCell, UITableViewHeaderFooterView, StubbedTableView>
    typealias Datasource = StaticDatasource<Factory>

    let view = StubbedTableView()
    let factory = Factory()
    let data: [Event] = map(0..<5) { (index) -> Event in Event.create() }
    var datasource: Datasource!

    var lessThanStartIndexPath: NSIndexPath {
        return NSIndexPath(forRow: data.count * -1, inSection: 0)
    }

    var validIndexPath: NSIndexPath {
        return NSIndexPath(forRow: 0, inSection: 0)
    }

    var greaterThanEndIndexPath: NSIndexPath {
        return NSIndexPath(forRow: data.count * 2, inSection: 0)
    }

    override func setUp() {
        factory.registerCell(.ClassWithIdentifier(UITableViewCell.self, "cell"), inView: view) { (_, _, _) in }
        datasource = Datasource(id: "test datasource", factory: factory, items: data)
    }

    func registerHeader(key: String? = .None, config: Factory.SupplementaryViewConfiguration) {
        registerSupplementaryView(.Header, key: key, config: config)
    }

    func registerFooter(key: String? = .None, config: Factory.SupplementaryViewConfiguration) {
        registerSupplementaryView(.Footer, key: key, config: config)
    }

    func registerSupplementaryView(kind: SupplementaryElementKind, key: String? = .None, config: Factory.SupplementaryViewConfiguration) {
        if let key = key {
            datasource.factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "\(kind)"), kind: kind, inView: view, withKey: key, configuration: config)
        }
        else {
            datasource.factory.registerSupplementaryView(.ClassWithIdentifier(UITableViewHeaderFooterView.self, "\(kind)"), kind: kind, inView: view, configuration: config)
        }
    }

    func validateSupplementaryView(kind: SupplementaryElementKind, exists: Bool, atIndexPath indexPath: NSIndexPath) {
        let supplementary = datasource.viewForSupplementaryElementInView(view, kind: kind, atIndexPath: indexPath)
        if exists {
            XCTAssertNotNil(supplementary, "Supplementary view should be returned.")
        }
        else {
            XCTAssertNil(supplementary, "No supplementary view should be returned.")
        }
    }

    func registerHeaderText(config: Factory.SupplementaryTextConfiguration) {
        registerSupplementaryText(.Header, config: config)
    }

    func registerFooterText(config: Factory.SupplementaryTextConfiguration) {
        registerSupplementaryText(.Footer, config: config)
    }

    func registerSupplementaryText(kind: SupplementaryElementKind, config: Factory.SupplementaryTextConfiguration) {
        datasource.factory.registerTextWithKind(kind, configuration: config)
    }
    
    func validateSupplementaryText(kind: SupplementaryElementKind, equals test: String?, atIndexPath indexPath: NSIndexPath) {
        let text: String? = datasource.textForSupplementaryElementInView(view, kind: kind, atIndexPath: indexPath)
        if let test = test {
            XCTAssertEqual(test, text!)
        }
        else {
            XCTAssertNil(text)
        }
    }
}

extension StaticDatasourceTests {

    func test_GivenStaticDatasource_ThatNumberOfSectionsIsOne() {
        XCTAssertEqual(datasource.numberOfSections, 1, "Number of sections should be 1 for a static data source")
    }

    func test_GivenStaticDatasource_ThatNumberOfItemIsCorrect() {
        XCTAssertEqual(datasource.numberOfItemsInSection(0), data.count, "The number of items should be equal in length to the items argument.")
    }

    func test_GivenStaticDatasource_WhenAccessingItemsAtANegativeIndex_ThatResultIsNone() {
        XCTAssertTrue(datasource.itemAtIndexPath(lessThanStartIndexPath) == nil, "Result should be none for negative indexes.")
    }

    func test_GivenStaticDatsource_WhenAccessingItemsGreaterThanMaxIndex_ThatResultIsNone() {
        XCTAssertTrue(datasource.itemAtIndexPath(greaterThanEndIndexPath) == nil, "Result should be none for indexes > max index.")
    }

    func test_GivenStaticDatasource_WhenAccessingItems_ThatCorrectItemIsReturned() {
        let item = datasource.itemAtIndexPath(validIndexPath)
        XCTAssertTrue(item != nil, "Item should not be nil.")
        XCTAssertEqual(item!, data[0], "Items at valid indexes should be correct.")
    }
}

extension StaticDatasourceTests {

    func test_GivenStaticDatasource_WhenAccessingCellAtValidIndex_ThatCellIsReturned() {
        let cell = datasource.cellForItemInView(view, atIndexPath: validIndexPath)
        XCTAssertNotNil(cell, "Cell should be returned")
    }
}

extension StaticDatasourceTests { // Cases where supplementary view should not be returned

    func test_GivenNoHeadersRegistered_WhenAccessingHeaderAtValidIndex_ThatResponseIsNone() {
        validateSupplementaryView(.Header, exists: false, atIndexPath: validIndexPath)
    }

    func test_GivenNoHeadersRegistered_WhenAccessingHeaderAtInvalidIndex_ThatResponseIsNone() {
        validateSupplementaryView(.Header, exists: false, atIndexPath: greaterThanEndIndexPath)
    }

    func test_GivenNoFootersRegistered_WhenAccessingFooterAtValidIndex_ThatResponseIsNone() {
        validateSupplementaryView(.Footer, exists: false, atIndexPath: validIndexPath)
    }

    func test_GivenNoFootersRegistered_WhenAccessingFooterAtInvalidIndex_ThatResponseIsNone() {
        validateSupplementaryView(.Footer, exists: false, atIndexPath: lessThanStartIndexPath)
    }

    func test_GivenNoCustomViewsRegistered_WhenAccessingCustomViewAtValidIndex_ThatResponseIsNone() {
        validateSupplementaryView(.Custom("Sidebar"), exists: false, atIndexPath: validIndexPath)
    }

    func test_GivenHeaderRegistered_WhenAccessingFooterAtValidIndex_ThatResponseIsNone() {
        registerHeader { (_, _) -> Void in }
        validateSupplementaryView(.Footer, exists: false, atIndexPath: validIndexPath)
    }

    func test_GivenHeaderRegistered_WhenAccessingFooterAtInvalidIndex_ThatResponseIsNone() {
        registerHeader { (_, _) -> Void in }
        validateSupplementaryView(.Footer, exists: false, atIndexPath: greaterThanEndIndexPath)
    }

    func test_GivenFooterRegistered_WhenAccessingHeaderAtValidIndex_ThatResponseIsNone() {
        registerFooter { (_, _) -> Void in }
        validateSupplementaryView(.Header, exists: false, atIndexPath: validIndexPath)
    }

    func test_GivenFooterRegistered_WhenAccessingHeaderAtInvalidIndex_ThatResponseIsNone() {
        registerFooter { (_, _) -> Void in }
        validateSupplementaryView(.Header, exists: false, atIndexPath: lessThanStartIndexPath)
    }
}

extension StaticDatasourceTests { // Cases where supplementary view should be returned

    func test_GivenHeaderRegistered_WhenAccessingHeaderAtValidIndex_ThatHeaderIsReturned() {
        registerHeader { (_, _) -> Void in }
        validateSupplementaryView(.Header, exists: true, atIndexPath: validIndexPath)
    }

    func test_GivenFooterRegistered_WhenAccessingFooterAtValidIndex_ThatFooterIsReturned() {
        registerFooter { (_, _) -> Void in }
        validateSupplementaryView(.Footer, exists: true, atIndexPath: validIndexPath)
    }

    func test_GivenCustomViewRegistered_WhenAccessingFooterAtValidIndex_ThatFooterIsReturned() {
        registerSupplementaryView(.Custom("Sidebar")) { (_, _) -> Void in }
        validateSupplementaryView(.Custom("Sidebar"), exists: true, atIndexPath: validIndexPath)
    }
}

extension StaticDatasourceTests {

    func test_GivenNoHeaderTextRegistered_WhenAccessingHeaderAtValidIndex_ThatResponseIsNone() {
        validateSupplementaryText(.Header, equals: .None, atIndexPath: validIndexPath)
    }

    func test_GivenNoHeaderTextRegistered_WhenAccessingHeaderAtInvalidIndex_ThatResponseIsNone() {
        validateSupplementaryText(.Header, equals: .None, atIndexPath: greaterThanEndIndexPath)
    }

    func test_GivenNoFooterTextRegistered_WhenAccessingFooterAtValidIndex_ThatResponseIsNone() {
        validateSupplementaryText(.Footer, equals: .None, atIndexPath: validIndexPath)
    }

    func test_GivenNoFooterTextRegistered_WhenAccessingFooterAtInvalidIndex_ThatResponseIsNone() {
        validateSupplementaryText(.Footer, equals: .None, atIndexPath: lessThanStartIndexPath)
    }

    func test_GivenHeaderTextRegistered_WhenAccessingFooterAtValidIndex_ThatResponseIsNone() {
        registerHeaderText { index in "Hello" }
        validateSupplementaryText(.Header, equals: "Hello", atIndexPath: validIndexPath)
    }

    func test_GivenFooterTextRegistered_WhenAccessingHeaderAtInvalidIndex_ThatResponseIsNone() {
        registerFooterText { index in "World" }
        validateSupplementaryText(.Footer, equals: "World", atIndexPath: validIndexPath)
    }
}

