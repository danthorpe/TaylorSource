//
//  ArrayDataSource.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 28/03/2016.
//
//

import Foundation

/**
 ArrayDataSource is a DataSourceType which is backed
 by a Swift Array.
 
 By definition, it only has one "section".
*/
public final class ArrayDataSource<
    Factory, Item
    where
    Factory: FactoryCellVendorType,
    Factory.CellIndexType == NSIndexPath,
    Factory: FactorySupplementaryViewVendorType,
    Factory.SupplementaryIndexType == NSIndexPath,
    Factory: FactorySupplementaryTextVendorType,
    Factory.TextType == String>: CellDataSourceType {

    public typealias ItemIndexType = Int
    public typealias ItemType = Item

    /// - returns: the Factory
    public let factory: Factory

    /// - returns: an optional String, can be used for debug identification
    public let identifier: String?

    /// - returns: an optional String, for the title
    public var title: String?

    /// - returns: mapper  which maps the cell index to the data source index
    public let transformCellIndexToItemIndex: NSIndexPath -> Int = { $0.item }

    public let transformItemToCellItem: Item throws -> Factory.ItemType

    private var items: [Item]

    /**
     Initializes an ArrayDataSource. It requires a factory, with an
     Array of values.
     
     - parameter identifier: an optiona; string identifier, defaults to .None
     - parameter factory: the factory instance
     - parameter items: an Array of Factory.ItemType
    */
    public init(identifier: String? = .None, factory: Factory, items: [Item], transform: Item throws -> Factory.ItemType) {
        self.identifier = identifier
        self.factory = factory
        self.items = items
        self.transformItemToCellItem = transform
    }

    /**
     The number of items
     - parameter section: the index of the section - is ignored
     - returns: an Int, the number of items in this section
     */
    public func numberOfItemsInSection(section: Int) -> Int {
        return items.count
    }

    /**
     The item at index path
     - parameter index: An index.
     - returns: An optional item at this index path
     */
    public func itemAtIndex(index: Int) throws -> Item {
        guard range.contains(index) else { throw DataSourceError.NoItemAtIndex(index) }
        return items[index]
    }

    /**
     The item at index path
     - parameter index: An index.
     - returns: An optional item at this index path
     */
    public func itemAtIndex(index: Factory.CellIndexType) throws -> Factory.ItemType {
        let item = try itemAtIndex(transformCellIndexToItemIndex(index))
        return try transformItemToCellItem(item)
    }

    /**
     Vends a configured cell for the item at this index.
     - parameter view: the cell based view (i.e. table view, or collection view)
     - parameter index: the index for the cell.
     */
    public func cellForItemInView(view: Factory.ViewType, atIndex index: Factory.CellIndexType) throws -> Factory.CellType {
        let item = try itemAtIndex(index)
        return try factory.cellForItem(item, inView: view, atIndex: index)
    }

    public func supplementaryViewForElementKind(kind: SupplementaryElementKind, inView view: Factory.ViewType, atIndex index: Factory.SupplementaryIndexType) -> Factory.SupplementaryViewType? {
        return factory.supplementaryViewForKind(kind, inView: view, atIndex: index)
    }

    public func supplementaryTextForElementKind(kind: SupplementaryElementKind, inView view: Factory.ViewType, atIndex index: Factory.SupplementaryIndexType) -> Factory.TextType? {
        return factory.supplementaryTextForKind(kind, atIndex: index)
    }
}

//extension ArrayDataSource where ItemType == Factory.ItemType {
//
//    public convenience init(identifier: String? = .None, factory: Factory, items: [Item]) {
//        self.dynamicType.init(identifier: identifier, factory: factory, items: items, transform: { $0 })
//    }
//}

