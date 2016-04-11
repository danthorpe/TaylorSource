//
//  FetchedResultsDataSource.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 10/04/2016.
//  Copyright © 2016 Daniel Thorpe. All rights reserved.
//

import Foundation
import CoreData

public protocol FetchedResultsController {

    var delegate: NSFetchedResultsControllerDelegate? { get set }

    var sections: [NSFetchedResultsSectionInfo]? { get }

    func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject
}

public extension FetchedResultsController {

    func itemAtIndexPath<T>(indexPath: NSIndexPath) throws -> T {
        guard let item = objectAtIndexPath(indexPath) as? T else {
            throw DataSourceError<NSIndexPath>.UnexpectedTypeAtIndex(indexPath)
        }
        return item
    }
}

extension NSFetchedResultsController: FetchedResultsController { }

public class FetchedResultsDataSource<
    Factory, Item
    where
    Factory: FactoryType,
    Factory.CellIndex == Factory.CellIndex.ViewIndex,
    Factory.CellIndex.ViewIndex == NSIndexPath,
    Factory.SupplementaryIndex == Factory.SupplementaryIndex.ViewIndex,
    Factory.SupplementaryIndex.ViewIndex == Int>: CellDataSourceType {

    public typealias ItemIndex = NSIndexPath

    /// - returns: the Factory
    public let factory: Factory

    /// - returns: an optional String, can be used for debug identification
    public let identifier: String?

    /// - returns: an optional String, for the title
    public var title: String? = .None

    /// - returns: transform which maps the item to the cell item
    public var transformItemToCellItem: Item throws -> Factory.Item

    private let fetchedResultsController: FetchedResultsController

    public init(identifier: String? = .None, factory: Factory, fetchedResultsController: FetchedResultsController, itemTransform: Item throws -> Factory.Item) {
        self.identifier = identifier
        self.factory = factory
        self.fetchedResultsController = fetchedResultsController
        self.transformItemToCellItem = itemTransform
    }
}

public extension FetchedResultsDataSource {

    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func numberOfItemsInSection(section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }

    func itemAtIndex(index: NSIndexPath) throws -> Item {
        return try fetchedResultsController.itemAtIndexPath(index)
    }
}

