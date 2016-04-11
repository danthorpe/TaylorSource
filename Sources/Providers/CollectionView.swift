//
//  CollectionView.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 11/04/2016.
//  Copyright © 2016 Daniel Thorpe. All rights reserved.
//

import UIKit

/**
 Providers which can create (and provide) a UICollectionViewDataSource
 object should conform to this protocol.
 */
public protocol UICollectionViewDataSourceProvider {
    
    /// - returns: an object which conforms to UICollectionViewDataSource
    var collectionViewDataSource: UICollectionViewDataSource { get }
}

public protocol CollectionViewType: CellBasedViewType { }

extension UICollectionView: CollectionViewType {
    public typealias CellIndex = NSIndexPath
    public typealias SupplementaryIndex = NSIndexPath
}

public struct CollectionViewDataSourceProvider<
    DataSourceProvider
    where
    DataSourceProvider: DataSourceProviderType,
    DataSourceProvider.DataSource: CellDataSourceType,
    DataSourceProvider.DataSource.Factory.View: CollectionViewType,
    DataSourceProvider.DataSource.Factory.Cell: UICollectionViewCell,
    DataSourceProvider.DataSource.Factory.SupplementaryView: UICollectionReusableView,
    DataSourceProvider.DataSource.Factory.CellIndex.ViewIndex == NSIndexPath,
    DataSourceProvider.DataSource.Factory.SupplementaryIndex.ViewIndex == NSIndexPath,
    DataSourceProvider.DataSource.Factory.Text == String>: DataSourceProviderType {

    public typealias DataSource = DataSourceProvider.DataSource
    public typealias Editor = DataSourceProvider.Editor
    internal typealias CollectionView = DataSource.Factory.View

    public let provider: DataSourceProvider

    public var dataSource: DataSource {
        return provider.dataSource
    }

    public var editor: Editor {
        return provider.editor
    }

    private let bridgedCollectionViewDataSource: BridgedCollectionViewDataSource

    public init(_ provider: DataSourceProvider) {
        self.provider = provider

        var bridged: BridgedCollectionViewDataSource

        let collectionViewDataSource = CollectionViewDataSource(
            numberOfSections: provider.dataSource.numberOfSectionsInCollectionView,
            numberOfItemsInSection: provider.dataSource.numberOfItemsInSectionInCollection,
            cellForItemAtIndexPath: provider.dataSource.cellForItemAtIndexPathInCollectionView,
            viewForElementKindAtIndexPath: provider.dataSource.viewForElementKindAtIndexPath
        )

        bridged = .Readonly(collectionViewDataSource)

        if provider.editor.capability.contains(Edit.Capability.Reorder) {
            bridged = bridged.addReorderCapability(provider.editor)
        }

        bridgedCollectionViewDataSource = bridged
    }
}

extension CollectionViewDataSourceProvider: UICollectionViewDataSourceProvider {

    public var collectionViewDataSource: UICollectionViewDataSource {
        return bridgedCollectionViewDataSource.collectionViewDataSource
    }
}

class CollectionViewDataSource: NSObject, UICollectionViewDataSource {

    typealias NumberOfSections = UICollectionView -> Int
    typealias NumberOfItemsInSection = (UICollectionView, Int) -> Int
    typealias CellForItemAtIndexPath = (UICollectionView, NSIndexPath) throws -> UICollectionViewCell
    typealias ViewForElementKindAtIndexPath = (UICollectionView, String, NSIndexPath) throws -> UICollectionReusableView

    let numberOfSections: NumberOfSections
    let numberOfItemsInSection: NumberOfItemsInSection
    let cellForItemAtIndexPath: CellForItemAtIndexPath
    let viewForElementKindAtIndexPath: ViewForElementKindAtIndexPath

    init(
        numberOfSections: NumberOfSections,
        numberOfItemsInSection: NumberOfItemsInSection,
        cellForItemAtIndexPath: CellForItemAtIndexPath,
        viewForElementKindAtIndexPath: ViewForElementKindAtIndexPath
        ) {
        self.numberOfSections = numberOfSections
        self.numberOfItemsInSection = numberOfItemsInSection
        self.cellForItemAtIndexPath = cellForItemAtIndexPath
        self.viewForElementKindAtIndexPath = viewForElementKindAtIndexPath
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return numberOfSections(collectionView)
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection(collectionView, section)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        do {
            return try cellForItemAtIndexPath(collectionView, indexPath)
        }
        catch {
            assertionFailure("Caught error dequeuing cell at index path: \(indexPath), error: \(error)")
            return UICollectionViewCell()
        }
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        do {
            return try viewForElementKindAtIndexPath(collectionView, kind, indexPath)
        }
        catch {
            assertionFailure("Caught error dequeuing supplementary view for kind: \(kind) at index path: \(indexPath), error: \(error)")
            return UICollectionReusableView()
        }
    }
}

class ReorderCollectionViewDataSource: CollectionViewDataSource {

    typealias CanMoveItemAtIndexPath = (UICollectionView, NSIndexPath) -> Bool
    typealias MoveItemAtIndexPathToIndexPath = (UICollectionView, NSIndexPath, NSIndexPath) -> Void

    let canMoveItemAtIndexPath: CanMoveItemAtIndexPath
    let moveItemAtIndexPathToIndexPath: MoveItemAtIndexPathToIndexPath

    init(collectionViewDataSource: CollectionViewDataSource, canMoveItemAtIndexPath: CanMoveItemAtIndexPath, moveItemAtIndexPathToIndexPath: MoveItemAtIndexPathToIndexPath) {
        self.canMoveItemAtIndexPath = canMoveItemAtIndexPath
        self.moveItemAtIndexPathToIndexPath = moveItemAtIndexPathToIndexPath
        super.init(numberOfSections: collectionViewDataSource.numberOfSections, numberOfItemsInSection: collectionViewDataSource.numberOfItemsInSection, cellForItemAtIndexPath: collectionViewDataSource.cellForItemAtIndexPath, viewForElementKindAtIndexPath: collectionViewDataSource.viewForElementKindAtIndexPath)
    }

    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return canMoveItemAtIndexPath(collectionView, indexPath)
    }

    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        moveItemAtIndexPathToIndexPath(collectionView, sourceIndexPath, destinationIndexPath)
    }
}

internal enum BridgedCollectionViewDataSource: UICollectionViewDataSourceProvider {
    case Readonly(CollectionViewDataSource)
    case Reorder(ReorderCollectionViewDataSource)

    var collectionViewDataSource: UICollectionViewDataSource {
        switch self {
        case .Readonly(let readonly):
            return readonly
        case .Reorder(let reorder):
            return reorder
        }
    }

    func addReorderCapability(editor: DataSourceEditorType) -> BridgedCollectionViewDataSource {
        guard editor.capability.contains(Edit.Capability.Reorder), case let .Readonly(readonly) = self else {
            return self
        }

        let reorderCollectionViewDataSource = ReorderCollectionViewDataSource(
            collectionViewDataSource: readonly,
            canMoveItemAtIndexPath: { [unowned editor] _, indexPath in
                editor.canEditItemAtIndexPath!(indexPath: indexPath)
            },
            moveItemAtIndexPathToIndexPath: { [unowned editor] _, from, to in
                editor.moveItemAtIndexPathToIndexPath?(from: from, to: to)
            }
        )

        return .Reorder(reorderCollectionViewDataSource)
    }
}

internal extension CellDataSourceType {

    var numberOfSectionsInCollectionView: CollectionViewDataSource.NumberOfSections {
        return { [unowned self] _ in self.numberOfSections }
    }

    var numberOfItemsInSectionInCollection: CollectionViewDataSource.NumberOfItemsInSection {
        return { [unowned self] _, section in self.numberOfItemsInSection(section) }
    }
}

internal extension CellDataSourceType where Factory.View: CollectionViewType, Factory.Cell: UICollectionViewCell, Factory.CellIndex.ViewIndex == NSIndexPath {

    var cellForItemAtIndexPathInCollectionView: CollectionViewDataSource.CellForItemAtIndexPath {
        return { [unowned self] (collectionView: UICollectionView, indexPath: NSIndexPath) in
            return try self.cellForItemInView(collectionView as! Factory.View, atIndex: indexPath) as UICollectionViewCell
        }
    }
}

internal extension CellDataSourceType where Factory.View: CollectionViewType, Factory.SupplementaryView: UICollectionReusableView, Factory.SupplementaryIndex.ViewIndex == NSIndexPath {

    var viewForElementKindAtIndexPath: CollectionViewDataSource.ViewForElementKindAtIndexPath {
        return { [unowned self] (collectionView: UICollectionView, kind: String, indexPath: NSIndexPath) in
            guard let supplementaryView = self.supplementaryViewForElementKind(SupplementaryElementKind(kind), inView: collectionView as! Factory.View, atIndex: indexPath) else {
                throw DataSourceError<NSIndexPath>.NoSupplementaryViewAtIndex(indexPath)
            }
            return supplementaryView as UICollectionReusableView
        }
    }
}







