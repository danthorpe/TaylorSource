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

    func itemAtIndexPath<T>(indexPath: NSIndexPath) throws -> T
}

public class FetchedResultsDataSource<
    Factory, Item
    where
    Factory: FactoryType,
    Factory.CellIndex.ViewIndex == NSIndexPath,
    Factory.CellIndex == NSIndexPath,
    Factory.SupplementaryIndex.ViewIndex == Int,
    Factory.SupplementaryIndex == Int>: CellDataSourceType {

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

