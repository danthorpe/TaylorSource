//
//  DataSource.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 11/03/2016.
//
//

import Foundation

/**
 DataSourceType is a protocol which describes the interface needed to vend
 items at indexes. It additionally provides APIs to support sectioning. It 
 has no concept of cells or views, see `CellDataSourceType`.
 
 This stripped down DataSourceType interface is well suited to "vending" 
 other items for things like `UIPageViewController` or similar where the
 `ItemType` may even be other data sources.
 */
public protocol DataSourceType {

    /// The associated index type
    associatedtype ItemIndexType

    /// The associated item type
    associatedtype ItemType

    /// - returns: an optional String, can be used for debug identification
    var identifier: String? { get }

    /// - returns: an optional String, for the title
    var title: String? { get }

    /// - returns: the number of sections in the datasource
    var numberOfSections: Int { get }

    /**
     The number of items in the section
     - parameter section: the index of the section
     - returns: an Int, the number of items in this section
     */
    func numberOfItemsInSection(section: Int) -> Int

    /**
     The item at index path
     - parameter index: An index.
     - returns: An optional item at this index path
     */
    func itemAtIndex(index: ItemIndexType) throws -> ItemType
}

/// Some default implementation
public extension DataSourceType {

    var numberOfSections: Int {
        return 1
    }
}

public extension DataSourceType {

    var totalNumberOfItems: Int {
        return (0..<numberOfSections).reduce(0) { $0 + numberOfItemsInSection($1) }
    }

    var startIndex: Int {
        return 0
    }

    var endIndex: Int {
        return totalNumberOfItems
    }

    var range: Range<Int> {
        return startIndex..<endIndex
    }
}

/**
 CellDataSourceType is a DataSourceType which is used to "drive" cell based views such as
 UITableView and UICollectionView. It therefore has an associated type, `Factory` which
 must conform to `FactoryType` and is responsible for registering and vending cells
 and supplementary views.
 
 To map between the underlying data source's indexing, and items, and those expected
 of the factory there are two transform properties (block). These are provided by
 default in the case where they are equal.
 */
public protocol CellDataSourceType: DataSourceType {

    /// The associated factory type
    associatedtype Factory: FactoryType

    /// - returns: the Factory
    var factory: Factory { get }

    /// - returns: transform which maps the cell index to the data source index
    var transformCellIndexToItemIndex: Factory.CellIndexType -> ItemIndexType { get }

    /// - returns: transform which maps the item to the cell item
    var transformItemToCellItem: ItemType throws -> Factory.ItemType { get }

    /**
     The item at index path
     - parameter indexPath: An index path.
     - returns: An optional item at this index path
     */
    func itemAtIndex(index: Factory.CellIndexType) throws -> Factory.ItemType

    /**
     Vends a configured cell for the item at this index.
     - parameter view: the cell based view (i.e. table view, or collection view)
     - parameter index: the index for the cell.
    */
    func cellForItemInView(view: Factory.ViewType, atIndex index: Factory.CellIndexType) throws -> Factory.CellType

    /**
     Vends an optional configured supplementary view for the correct element at index.
     - parameter kind: a SupplementaryElementKind value
     - parameter view: the cell based view (i.e. table view, or collection view)
     - parameter index: the index for the supplementary view
     - returns: an optional instance of SupplementaryViewType
    */
    func supplementaryViewForElementKind(kind: SupplementaryElementKind, inView view: Factory.ViewType, atIndex index: Factory.SupplementaryIndexType) -> Factory.SupplementaryViewType?

    /**
     Vends optional text for the supplementary element at index.
     - parameter kind: a SupplementaryElementKind value
     - parameter view: the cell based view (i.e. table view, or collection view)
     - parameter index: the index for the supplementary view
     - returns: an optional instance of TextType
    */
    func supplementaryTextForElementKind(kind: SupplementaryElementKind, inView view: Factory.ViewType, atIndex index: Factory.SupplementaryIndexType) -> Factory.TextType?
}

public extension CellDataSourceType {

    /**
     The cell item at the cell index. This method will transform the cell
     index into an index into the data source, try to get the data item,
     and then transform that into a cell item.
     - parameter index: A cell index.
     - returns: an item for the cell.
     */
    public func itemAtIndex(index: Factory.CellIndexType) throws -> Factory.ItemType {
        let item = try itemAtIndex(transformCellIndexToItemIndex(index))
        return try transformItemToCellItem(item)
    }
}

public extension CellDataSourceType where Factory: FactoryCellVendorType {

    /**
     Vends a configured cell for the item at this index.
     - parameter view: the cell based view (i.e. table view, or collection view)
     - parameter index: the index for the cell.
     */
    public func cellForItemInView(view: Factory.ViewType, atIndex index: Factory.CellIndexType) throws -> Factory.CellType {
        let item = try itemAtIndex(index)
        return try factory.cellForItem(item, inView: view, atIndex: index)
    }
}

public extension CellDataSourceType where Factory: FactorySupplementaryViewVendorType {

    public func supplementaryViewForElementKind(kind: SupplementaryElementKind, inView view: Factory.ViewType, atIndex index: Factory.SupplementaryIndexType) -> Factory.SupplementaryViewType? {
        return factory.supplementaryViewForKind(kind, inView: view, atIndex: index)
    }
}

public extension CellDataSourceType where Factory: FactorySupplementaryTextVendorType {

    public func supplementaryTextForElementKind(kind: SupplementaryElementKind, inView view: Factory.ViewType, atIndex index: Factory.SupplementaryIndexType) -> Factory.TextType? {
        return factory.supplementaryTextForKind(kind, atIndex: index)
    }
}

public extension CellDataSourceType where Factory.CellIndexType == ItemIndexType {

    var transformCellIndexToItemIndex: Factory.CellIndexType -> ItemIndexType {
        return { $0 }
    }
}

public extension CellDataSourceType where Factory.ItemType == ItemType {

    var transformItemToCellItem: Factory.ItemType -> ItemType {
        return { $0 }
    }
}

public enum DataSourceError<Index: Equatable>: ErrorType, Equatable {
    case NoItemAtIndex(Index)
}

public func == <Index: Equatable> (lhs: DataSourceError<Index>, rhs: DataSourceError<Index>) -> Bool {
    switch (lhs, rhs) {
    case let (.NoItemAtIndex(lhsIndex), .NoItemAtIndex(rhsIndex)):
        return lhsIndex == rhsIndex
    }
}

