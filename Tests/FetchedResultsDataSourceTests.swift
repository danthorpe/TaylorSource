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
        fetchedResultsController = TestableFetchedResultsController()
        fetchedResultsController.sections = [ createSection() ]
        indexPath = NSIndexPath(forRow: 0, inSection: 0)
    }
    
    override func tearDown() {
        fetchedResultsController = nil
        super.tearDown()
    }
    
    func createSection(name: String = "A Section", objects: [AnyObject]? = ["Hello World"]) -> FetchedResultsSectionInfo {
        let section = FetchedResultsSectionInfo()
        section.name = name
        section.objects = objects
        return section
    }
 
    func test__itemAtIndexPath() {
        let item: String = XCTAssertNoThrows(try fetchedResultsController.itemAtIndexPath(indexPath))
        XCTAssertEqual(item, "Hello World")
    }
    
    func test__itemAtIndexPath__unexpected_type__throws_error() {
        XCTAssertThrowsError(try fetchedResultsController.itemAtIndexPath(indexPath) as NSNumber, DataSourceError<NSIndexPath>.UnexpectedTypeAtIndex(indexPath))
    }
}

class FetchedResultsDataSourceTests: XCTestCase {
    
}