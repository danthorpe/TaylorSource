//
//  DataSource.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 11/03/2016.
//
//

import Foundation

public protocol DataSourceType {

    /// The associated factory type
    associatedtype Factory: FactoryType

    /// The factory
    var factory: Factory { get }

    /// An optional title
    var title: String? { get }

    /// An optional identifier
    var identifier: String? { get }

    /// The number of sections in the datasource
    var numberOfSections: Int { get }

    /**
     The number of items in the section
     - parameter section: the index of the section
     - returns: an Int, the number of items in this section
    */
    func numberOfItemsInSection(section: Int) -> Int

    /**
     The item at index path
     - parameter indexPath: An index path.
     - returns: An optional item at this index path
    */
    func itemAtIndexPath(indexPath: NSIndexPath) -> Factory.ItemType?

    /**
     Vends a configured cell for the item at this index path.
     - parameter view: the cell based view (i.e. table view, or collection view)
     - parameter indexPath: the indexPath for the cell.
    */
    func cellForItemInView(view: Factory.ViewType, atIndexPath indexPath: NSIndexPath) -> Factory.CellType
}
