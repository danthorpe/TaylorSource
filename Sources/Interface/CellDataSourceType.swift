//
//  CellDataSourceType.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 09/04/2016.
//  Copyright © 2016 Daniel Thorpe. All rights reserved.
//

import Foundation

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
    var transformCellIndexToItemIndex: Factory.CellIndex.ViewIndex -> ItemIndex { get }

    /// - returns: transform which maps the item to the cell item
    var transformItemToCellItem: Item throws -> Factory.Item { get }

    /**
     The item at index path
     - parameter indexPath: An index path.
     - returns: An optional item at this index path
     */
    func itemAtIndex(index: Factory.CellIndex.ViewIndex) throws -> Factory.Item

    /**
     Vends a configured cell for the item at this index.
     - parameter view: the cell based view (i.e. table view, or collection view)
     - parameter index: the index for the cell.
     */
    func cellForItemInView(view: Factory.View, atIndex index: Factory.CellIndex.ViewIndex) throws -> Factory.Cell

    /**
     Vends an optional configured supplementary view for the correct element at index.
     - parameter kind: a SupplementaryElementKind value
     - parameter view: the cell based view (i.e. table view, or collection view)
     - parameter index: the index for the supplementary view
     - returns: an optional instance of SupplementaryViewType
     */
    func supplementaryViewForElementKind(kind: SupplementaryElementKind, inView view: Factory.View, atIndex index: Factory.SupplementaryIndex.ViewIndex) -> Factory.SupplementaryView?

    /**
     Vends optional text for the supplementary element at index.
     - parameter kind: a SupplementaryElementKind value
     - parameter view: the cell based view (i.e. table view, or collection view)
     - parameter index: the index for the supplementary view
     - returns: an optional instance of TextType
     */
    func supplementaryTextForElementKind(kind: SupplementaryElementKind, inView view: Factory.View, atIndex index: Factory.SupplementaryIndex.ViewIndex) -> Factory.Text?
}

public extension CellDataSourceType {

    /**
     The cell item at the cell index. This method will transform the cell
     index into an index into the data source, try to get the data item,
     and then transform that into a cell item.
     - parameter index: A cell index.
     - returns: an item for the cell.
     */
    public func itemAtIndex(index: Factory.CellIndex.ViewIndex) throws -> Factory.Item {
        let item = try itemAtIndex(transformCellIndexToItemIndex(index))
        return try transformItemToCellItem(item)
    }
}

public extension CellDataSourceType where Factory: FactoryCellVendorType, Factory.CellIndex.ViewIndex == Factory.CellIndex {

    /**
     Vends a configured cell for the item at this index.
     - parameter view: the cell based view (i.e. table view, or collection view)
     - parameter index: the index for the cell.
     */
    public func cellForItemInView(view: Factory.View, atIndex index: Factory.CellIndex.ViewIndex) throws -> Factory.Cell {
        let item = try itemAtIndex(index)
        return try factory.cellForItem(item, inView: view, atIndex: index)
    }
}

public extension CellDataSourceType where Factory: FactorySupplementaryViewVendorType, Factory.SupplementaryIndex.ViewIndex == Factory.SupplementaryIndex {

    public func supplementaryViewForElementKind(kind: SupplementaryElementKind, inView view: Factory.View, atIndex index: Factory.SupplementaryIndex.ViewIndex) -> Factory.SupplementaryView? {
        return factory.supplementaryViewForKind(kind, inView: view, atIndex: index)
    }
}

public extension CellDataSourceType where Factory: FactorySupplementaryTextVendorType, Factory.SupplementaryIndex.ViewIndex == Factory.SupplementaryIndex {

    public func supplementaryTextForElementKind(kind: SupplementaryElementKind, inView view: Factory.View, atIndex index: Factory.SupplementaryIndex.ViewIndex) -> Factory.Text? {
        return factory.supplementaryTextForKind(kind, atIndex: index)
    }
}

public extension CellDataSourceType where Factory.CellIndex.ViewIndex == ItemIndex {

    var transformCellIndexToItemIndex: Factory.CellIndex.ViewIndex -> ItemIndex {
        return { $0 }
    }
}

public extension CellDataSourceType where Factory.Item == Item {

    var transformItemToCellItem: Item -> Factory.Item {
        return { $0 }
    }
}
