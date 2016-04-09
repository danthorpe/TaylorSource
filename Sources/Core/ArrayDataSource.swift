//
//  ArrayDataSource.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 28/03/2016.
//
//

import Foundation

public final class ArrayDataSource<
    Factory
    where
    Factory: FactoryCellVendorType,
    Factory.CellIndexType == NSIndexPath,
    Factory: FactorySupplementaryViewVendorType,
    Factory.SupplementaryIndexType == NSIndexPath,
    Factory: FactorySupplementaryTextVendorType,
    Factory.TextType == String>: DataSourceType {

    public let identifier: String?

    public let factory: Factory

    public var title: String?

    public let cellIndexMapper: NSIndexPath -> Int = { $0.item }

    private var items: [Factory.ItemType]
    private var range: Range<Int>

    public init(id: String? = .None, factory: Factory, items: [Factory.ItemType]) {
        self.identifier = id
        self.factory = factory
        self.items = items
        self.range = items.startIndex..<items.endIndex
    }

    public func numberOfItemsInSection(section: Int) -> Int {
        return items.count
    }

    public func itemAtIndex(index: Int) throws -> Factory.ItemType {
        guard range.contains(index) else { throw DataSourceError.NoItemAtIndex(index) }
        return items[index]
    }

    public func cellForItemInView(view: Factory.ViewType, atIndex index: Factory.CellIndexType) throws -> Factory.CellType {
        let item = try itemAtIndex(cellIndexMapper(index))
        return try factory.cellForItem(item, inView: view, atIndex: index)
    }

    public func supplementaryViewForElementKind(kind: SupplementaryElementKind, inView view: Factory.ViewType, atIndex index: Factory.SupplementaryIndexType) -> Factory.SupplementaryViewType? {
        return factory.supplementaryViewForKind(kind, inView: view, atIndex: index)
    }

    public func supplementaryTextForElementKind(kind: SupplementaryElementKind, inView view: Factory.ViewType, atIndex index: Factory.SupplementaryIndexType) -> Factory.TextType? {
        return factory.supplementaryTextForKind(kind, atIndex: index)
    }
}

