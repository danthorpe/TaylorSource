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
     The data item at index
     - parameter index: An index.
     - returns: the item at this index, else throws a DataSourceError
     */
    public func itemAtIndex(index: Int) throws -> Item {
        guard range.contains(index) else { throw DataSourceError.NoItemAtIndex(index) }
        return items[index]
    }
}

//extension ArrayDataSource where ItemType == Factory.ItemType {
//
//    public convenience init(identifier: String? = .None, factory: Factory, items: [Item]) {
//        self.dynamicType.init(identifier: identifier, factory: factory, items: items, transform: { $0 })
//    }
//}

