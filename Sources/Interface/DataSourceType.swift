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
    associatedtype ItemIndex

    /// The associated item type
    associatedtype Item

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
    func itemAtIndex(index: ItemIndex) throws -> Item
}

/// Default implementations
public extension DataSourceType {

    /// - returns: the number of sections in the datasource
    var numberOfSections: Int {
        return 1
    }
}

/// Additional public APIs
public extension DataSourceType {

    /// - returns: the total number of items
    var totalNumberOfItems: Int {
        return (0..<numberOfSections).reduce(0) { $0 + numberOfItemsInSection($1) }
    }

    /// - returns: the startIndex, default of 0
    var startIndex: Int {
        return 0
    }

    /// - returns: the endIndex
    var endIndex: Int {
        return totalNumberOfItems
    }

    /// - returns: a Range<Int> using the start and end indexes
    var range: Range<Int> {
        return startIndex..<endIndex
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

