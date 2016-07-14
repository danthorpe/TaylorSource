import UIKit
import XCTest
import TaylorSource

class StaticSectionDatasourceTests: XCTestCase {

    typealias Factory = BasicFactory<Event, UITableViewCell, UITableViewHeaderFooterView, StubbedTableView>
    typealias Datasource = StaticSectionDatasource<Factory, EventSection>

    let view = StubbedTableView()
    let factory = Factory()

    let sectionCount = 4
    let itemCount = 5

    lazy var sections: [EventSection] = (0 ..< self.sectionCount).map { section in
        let items = (0 ..< self.itemCount).map { (index) -> Event in Event.create() }
        return EventSection(title: "Section \(section)", items: items)
    }

    var datasource: Datasource!
    var provider: BasicDatasourceProvider<Datasource>!

    var validIndexPath: NSIndexPath {
        return NSIndexPath(forRow: 0, inSection: 0)
    }

    var lessThanStartItemIndexPath: NSIndexPath {
        return NSIndexPath(forRow: -1, inSection: 0)
    }

    var greaterThanEndItemIndexPath: NSIndexPath {
        return NSIndexPath(forRow: sections[0].items.count * 2, inSection: 0)
    }

    var lessThanStartSectionIndexPath: NSIndexPath {
        return NSIndexPath(forRow: 0, inSection: -1)
    }

    var greaterThanEndSectionIndexPath: NSIndexPath {
        return NSIndexPath(forRow: 0, inSection: sections.count * 2)
    }


    override func setUp() {
        factory.registerCell(.ClassWithIdentifier(UITableViewCell.self, "cell"), inView: view) { (_, _, _) in }
        datasource = Datasource(id: "test datasource", factory: factory, sections: sections)
        provider = BasicDatasourceProvider(datasource)
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

extension StaticSectionDatasourceTests {

    func test_BasicDatasourceProvider_VendsDatasource() {
        XCTAssertNotNil(provider.datasource)
    }

    func test_StaticDatasource_DatasourceIsASequence() {
        XCTAssertEqual(datasource.generate().map { $0.title }, sections.map { $0.title })
    }

    func test_StaticDatasource_DatasourceStartIndexIsZero() {
        XCTAssertEqual(datasource.startIndex, 0)
    }

    func test_StaticDatasource_DatasourceEndIndexIsCorrect() {
        XCTAssertEqual(datasource.endIndex, sectionCount)
    }

    func test_StaticDatasource_DataSourceAllowsRandomAccess() {
        for sectionIndex in 0 ..< sectionCount {
            XCTAssertEqual(datasource[sectionIndex], sections[sectionIndex])
        }
    }

    func test_StaticDatasource_SectionsArePresent() {
        XCTAssertEqual(datasource.numberOfSections, sections.count)
        for sectionIndex in 0 ..< datasource.numberOfSections {
            XCTAssertNotNil(provider.datasource.sectionAtIndex(sectionIndex))
        }
    }

    func test_StaticDatasource_SectionsAreSequences() {
        for (index, section) in datasource.enumerate() {
            XCTAssertEqual(section.generate().map { $0.color }, sections[index].map { $0.color })
        }
    }

    func test_StaticDatasource_SectionsStartAtIndex0() {
        for section in datasource {
            XCTAssertEqual(section.startIndex, 0)
        }
    }

    func test_StaticDatasource_SectionsEndAtCorrectIndex() {
        for section in datasource {
            XCTAssertEqual(section.endIndex, itemCount)
        }
    }

    func test_StaticDatasource_SectionsAllowsRandomAccess() {
        for sectionIndex in 0 ..< sectionCount {
            for itemIndex in 0 ..< itemCount {
                XCTAssertEqual(datasource[sectionIndex][itemIndex], sections[sectionIndex][itemIndex])
            }
        }
    }
}

extension StaticSectionDatasourceTests {

    func test_GivenStaticDatasource_ThatNumberOfSectionsIsCorrect() {
        XCTAssertEqual(datasource.numberOfSections, sections.count, "The number of sections should be equal to the sections argument.")
    }

    func test_GivenStaticDatasource_WhenAccessingItems_AtANegativeIndex_ThatResultIsNone() {
        XCTAssertTrue(datasource.itemAtIndexPath(lessThanStartSectionIndexPath) == nil, "Result should be none for negative indexes.")
        XCTAssertTrue(datasource.itemAtIndexPath(lessThanStartItemIndexPath) == nil, "Result should be none for negative indexes.")
    }

    func test_GivenStaticDatsource_WhenAccessingItems_GreaterThanMaxIndex_ThatResultIsNone() {
        XCTAssertTrue(datasource.itemAtIndexPath(greaterThanEndSectionIndexPath) == nil, "Result should be none for indexes > max index.")
        XCTAssertTrue(datasource.itemAtIndexPath(greaterThanEndItemIndexPath) == nil, "Result should be none for indexes > max index.")
    }

    func test_GivenStaticDatasource_WhenAccessingItems_AtValidIndexPath_ThatCorrectItemIsReturned() {
        let item = datasource.itemAtIndexPath(validIndexPath)
        XCTAssertTrue(item != nil, "Item should not be nil.")
        XCTAssertEqual(item!, sections[validIndexPath.section][validIndexPath.item], "Items at valid indexes should be correct.")
    }
}

extension StaticSectionDatasourceTests {

    func test_GivenStaticDatasource_WhenAccessingCellAtValidIndex_ThatCellIsReturned() {
        let cell = datasource.cellForItemInView(view, atIndexPath: validIndexPath)
        XCTAssertNotNil(cell, "Cell should be returned")
    }
}

extension StaticSectionDatasourceTests { // Cases where supplementary view should not be returned

    func test_GivenNoHeadersRegistered_WhenAccessingHeaderAtValidIndex_ThatResponseIsNone() {
        validateSupplementaryView(.Header, exists: false, atIndexPath: validIndexPath)
    }

    func test_GivenNoHeadersRegistered_WhenAccessingHeaderAtInvalidIndex_ThatResponseIsNone() {
        validateSupplementaryView(.Header, exists: false, atIndexPath: greaterThanEndSectionIndexPath)
        validateSupplementaryView(.Header, exists: false, atIndexPath: greaterThanEndItemIndexPath)
        validateSupplementaryView(.Header, exists: false, atIndexPath: lessThanStartSectionIndexPath)
        validateSupplementaryView(.Header, exists: false, atIndexPath: lessThanStartItemIndexPath)
    }

    func test_GivenNoFootersRegistered_WhenAccessingFooterAtValidIndex_ThatResponseIsNone() {
        validateSupplementaryView(.Footer, exists: false, atIndexPath: validIndexPath)
    }

    func test_GivenNoFootersRegistered_WhenAccessingFooterAtInvalidIndex_ThatResponseIsNone() {
        validateSupplementaryView(.Footer, exists: false, atIndexPath: greaterThanEndSectionIndexPath)
        validateSupplementaryView(.Footer, exists: false, atIndexPath: greaterThanEndItemIndexPath)
        validateSupplementaryView(.Footer, exists: false, atIndexPath: lessThanStartSectionIndexPath)
        validateSupplementaryView(.Footer, exists: false, atIndexPath: lessThanStartItemIndexPath)
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
        validateSupplementaryView(.Footer, exists: false, atIndexPath: greaterThanEndSectionIndexPath)
        validateSupplementaryView(.Footer, exists: false, atIndexPath: greaterThanEndItemIndexPath)
        validateSupplementaryView(.Footer, exists: false, atIndexPath: lessThanStartSectionIndexPath)
        validateSupplementaryView(.Footer, exists: false, atIndexPath: lessThanStartItemIndexPath)
    }

    func test_GivenFooterRegistered_WhenAccessingHeaderAtValidIndex_ThatResponseIsNone() {
        registerFooter { (_, _) -> Void in }
        validateSupplementaryView(.Header, exists: false, atIndexPath: validIndexPath)
    }

    func test_GivenFooterRegistered_WhenAccessingHeaderAtInvalidIndex_ThatResponseIsNone() {
        registerFooter { (_, _) -> Void in }
        validateSupplementaryView(.Header, exists: false, atIndexPath: greaterThanEndSectionIndexPath)
        validateSupplementaryView(.Header, exists: false, atIndexPath: greaterThanEndItemIndexPath)
        validateSupplementaryView(.Header, exists: false, atIndexPath: lessThanStartSectionIndexPath)
        validateSupplementaryView(.Header, exists: false, atIndexPath: lessThanStartItemIndexPath)
    }
}

extension StaticSectionDatasourceTests { // Cases where supplementary view should be returned

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

extension StaticSectionDatasourceTests {

    func test_GivenNoHeaderTextRegistered_WhenAccessingHeaderAtValidIndex_ThatResponseIsNone() {
        validateSupplementaryText(.Header, equals: .None, atIndexPath: validIndexPath)
    }

    func test_GivenNoHeaderTextRegistered_WhenAccessingHeaderAtInvalidIndex_ThatResponseIsNone() {
        validateSupplementaryText(.Header, equals: .None, atIndexPath: greaterThanEndSectionIndexPath)
        validateSupplementaryText(.Header, equals: .None, atIndexPath: greaterThanEndItemIndexPath)
        validateSupplementaryText(.Header, equals: .None, atIndexPath: lessThanStartSectionIndexPath)
        validateSupplementaryText(.Header, equals: .None, atIndexPath: lessThanStartItemIndexPath)
    }

    func test_GivenNoFooterTextRegistered_WhenAccessingFooterAtValidIndex_ThatResponseIsNone() {
        validateSupplementaryText(.Footer, equals: .None, atIndexPath: validIndexPath)
    }

    func test_GivenNoFooterTextRegistered_WhenAccessingFooterAtInvalidIndex_ThatResponseIsNone() {
        validateSupplementaryText(.Footer, equals: .None, atIndexPath: greaterThanEndSectionIndexPath)
        validateSupplementaryText(.Footer, equals: .None, atIndexPath: greaterThanEndItemIndexPath)
        validateSupplementaryText(.Footer, equals: .None, atIndexPath: lessThanStartSectionIndexPath)
        validateSupplementaryText(.Footer, equals: .None, atIndexPath: lessThanStartItemIndexPath)
    }

    func test_GivenHeaderTextRegistered_WhenAccessingFooterAtValidIndex_ThatResponseIsNone() {
        registerHeaderText { index in "Hello" }
        validateSupplementaryText(.Footer, equals: .None, atIndexPath: validIndexPath)
    }

    func test_GivenFooterTextRegistered_WhenAccessingHeaderAtInvalidIndex_ThatResponseIsNone() {
        registerFooterText { index in "World" }
        validateSupplementaryText(.Header, equals: .None, atIndexPath: validIndexPath)
    }

    func test_GivenHeaderTextRegistered_WhenAccessingHeaderAtValidIndex_ThatResponseIsReturned() {
        registerHeaderText { index in "Hello" }
        validateSupplementaryText(.Header, equals: "Hello", atIndexPath: validIndexPath)
    }

    func test_GivenFooterTextRegistered_WhenAccessingHeaderAtInvalidIndex_ThatResponseIsReturned() {
        registerFooterText { index in "World" }
        validateSupplementaryText(.Footer, equals: "World", atIndexPath: validIndexPath)
    }
}


