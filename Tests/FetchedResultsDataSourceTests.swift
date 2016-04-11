//
//  FetchedResultsDataSourceTests.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 11/04/2016.
//  Copyright © 2016 Daniel Thorpe. All rights reserved.
//

import Foundation
import CoreData
import XCTest
@testable import TaylorSource

class FetchedResultsSectionInfo: NSObject, NSFetchedResultsSectionInfo {
    var name: String = "A Section Name"
    var indexTitle: String? = .None
    var numberOfObjects: Int = 0
    var objects: [AnyObject]? = .None {
        didSet {
            numberOfObjects = objects?.count ?? 0
        }
    }
}

class TestableFetchedResultsController: NSObject, FetchedResultsController {
    
    var delegate: NSFetchedResultsControllerDelegate?
    
    var sections: [NSFetchedResultsSectionInfo]?
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        guard let
            section = sections?[indexPath.section],
            object = section.objects?[indexPath.row]
        else { fatalError() }
        return object
    }
}

class FetchedResultsControllerTests: XCTestCase {

    var fetchedResultsController: TestableFetchedResultsController!
    var indexPath: NSIndexPath!
    
    override func setUp() {
        super.setUp()
        indexPath = NSIndexPath(forRow: 0, inSection: 0)
        fetchedResultsController = TestableFetchedResultsController()
        setupAgain()
    }
    
    func setupAgain(objects: [AnyObject]? = ["Hello", "World"]) {
        fetchedResultsController.sections = [
            createSection(objects: objects),
            createSection(objects: objects)
        ]
    }
    
    override func tearDown() {
        fetchedResultsController = nil
        super.tearDown()
    }
    
    func createSection(name: String = "A Section", objects: [AnyObject]? = ["Hello", "World"]) -> FetchedResultsSectionInfo {
        let section = FetchedResultsSectionInfo()
        section.name = name
        section.objects = objects
        return section
    }
 }

class FetchedResultsControllerExtensionTests: FetchedResultsControllerTests {

    func test__itemAtIndexPath() {
        let item: String = XCTAssertNoThrows(try fetchedResultsController.itemAtIndexPath(indexPath))
        XCTAssertEqual(item, "Hello")
    }
    
    func test__itemAtIndexPath__unexpected_type__throws_error() {
        XCTAssertThrowsError(try fetchedResultsController.itemAtIndexPath(indexPath) as NSNumber, DataSourceError<NSIndexPath>.UnexpectedTypeAtIndex(indexPath))
    }
}

class FetchedResultsDataSourceTests: FetchedResultsControllerTests {
    
    typealias DataSource = FetchedResultsDataSource<TestableFactory, String>
    
    var tableView: TestableTable!
    var factory: DataSource.Factory!
    var dataSource: DataSource!
    
    override func setUp() {
        super.setUp()
        tableView = TestableTable()
        factory = DataSource.Factory()
        dataSource = DataSource(factory: factory, fetchedResultsController: fetchedResultsController, itemTransform: { $0 })
    }
    
    override func tearDown() {
        tableView = nil
        factory = nil
        dataSource = nil
        super.tearDown()
    }
    
    func test__numberOfSections() {
        XCTAssertEqual(dataSource.numberOfSections, 2)
    }
    
    func test__numberOfSections__when_results_empty() {
        fetchedResultsController.sections = nil
        XCTAssertEqual(dataSource.numberOfSections, 0)
    }
    
    func test__numberOfItemsInSection() {
        XCTAssertEqual(dataSource.numberOfItemsInSection(0), 2)
        XCTAssertEqual(dataSource.numberOfItemsInSection(1), 2)
    }
    
    func test__numberOfItemsInSection__when_results_empty() {
        fetchedResultsController.sections = nil
        XCTAssertEqual(dataSource.numberOfItemsInSection(0), 0)
    }
    
    func test__itemAtIndexPath() {
        let item = XCTAssertNoThrows(try dataSource.itemAtIndex(indexPath))
        XCTAssertEqual(item, "Hello")
    }
    
    func test__itemAtIndexPath__unexpected_type__throws_error() {
        setupAgain([NSNumber(integer: 0), NSNumber(integer: 1)])
        XCTAssertThrowsError(try dataSource.itemAtIndex(indexPath), DataSourceError<NSIndexPath>.UnexpectedTypeAtIndex(indexPath))
    }
}