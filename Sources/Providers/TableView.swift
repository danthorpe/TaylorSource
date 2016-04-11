//
//  TableView.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 09/04/2016.
//  Copyright © 2016 Daniel Thorpe. All rights reserved.
//

import UIKit

/**
 Providers which can create (and provide) a UITableViewDataSource
 object should conform to this protocol.
 */
public protocol UITableViewDataSourceProvider {

    /// - returns: an object which conforms to UITableViewDataSource
    var tableViewDataSource: UITableViewDataSource { get }
}

public protocol TableViewType: CellBasedViewType { }

extension UITableView: TableViewType {
    public typealias CellIndex = NSIndexPath
    public typealias SupplementaryIndex = Int
}

public struct TableViewDataSourceProvider<
    DataSourceProvider
    where
    DataSourceProvider: DataSourceProviderType,
    DataSourceProvider.DataSource: CellDataSourceType,
    DataSourceProvider.DataSource.Factory.View: TableViewType,
    DataSourceProvider.DataSource.Factory.Cell: UITableViewCell,
    DataSourceProvider.DataSource.Factory.SupplementaryView: UITableViewHeaderFooterView,
    DataSourceProvider.DataSource.Factory.CellIndex.ViewIndex == NSIndexPath,
    DataSourceProvider.DataSource.Factory.SupplementaryIndex.ViewIndex == Int,
    DataSourceProvider.DataSource.Factory.Text == String>: DataSourceProviderType {

    public typealias DataSource = DataSourceProvider.DataSource
    public typealias Editor = DataSourceProvider.Editor
    internal typealias TableView = DataSource.Factory.View

    public let provider: DataSourceProvider

    public var dataSource: DataSource {
        return provider.dataSource
    }

    public var editor: Editor {
        return provider.editor
    }

    private let bridgedTableViewDataSource: BridgedTableViewDataSource

    public init(_ provider: DataSourceProvider) {
        self.provider = provider

        var bridged: BridgedTableViewDataSource

        let tableViewDataSource = TableViewDataSource(
            numberOfSections: provider.dataSource.numberOfSectionsInTableView,
            numberOfRowsInSection: provider.dataSource.numberOfRowsInSectionInTableView,
            cellForRowAtIndexPath: provider.dataSource.cellForRowAtIndexPathInTableView,
            titleForHeaderInSection: provider.dataSource.titleForHeaderInSectionInTableView,
            titleForFooterInSection: provider.dataSource.titleForFooterInSectionInTableView)

        bridged = .Readonly(tableViewDataSource)

        if provider.editor.capability.contains(Edit.Capability.InsertDelete) {
            bridged = bridged.addInsertDeleteCapability(provider.editor)
        }

        if provider.editor.capability.contains([Edit.Capability.InsertDelete, Edit.Capability.Reorder]) {
            bridged = bridged.addFullEditableCapability(provider.editor)
        }

        bridgedTableViewDataSource = bridged
    }
}

extension TableViewDataSourceProvider: UITableViewDataSourceProvider {

    public var tableViewDataSource: UITableViewDataSource {
        return bridgedTableViewDataSource.tableViewDataSource
    }
}

internal class TableViewDataSource: NSObject, UITableViewDataSource {

    typealias NumberOfSections = UITableView -> Int
    typealias NumberOfRowsInSection = (UITableView, Int) -> Int
    typealias CellForRowAtIndexPath = (UITableView, NSIndexPath) throws -> UITableViewCell
    typealias TitleInSection = (UITableView, Int) -> String?

    let numberOfSections: NumberOfSections
    let numberOfRowsInSection: NumberOfRowsInSection
    let cellForRowAtIndexPath: CellForRowAtIndexPath
    let titleForHeaderInSection: TitleInSection
    let titleForFooterInSection: TitleInSection

    init(
        numberOfSections: NumberOfSections,
        numberOfRowsInSection: NumberOfRowsInSection,
        cellForRowAtIndexPath: CellForRowAtIndexPath,
        titleForHeaderInSection: TitleInSection,
        titleForFooterInSection: TitleInSection) {

        self.numberOfSections = numberOfSections
        self.numberOfRowsInSection = numberOfRowsInSection
        self.cellForRowAtIndexPath = cellForRowAtIndexPath
        self.titleForHeaderInSection = titleForHeaderInSection
        self.titleForFooterInSection = titleForFooterInSection
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfSections(tableView)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection(tableView, section)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        do {
            return try cellForRowAtIndexPath(tableView, indexPath)
        }
        catch {
            assertionFailure("Caught error dequeing cell, \(error)")
            return UITableViewCell()
        }
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeaderInSection(tableView, section)
    }

    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return titleForFooterInSection(tableView, section)
    }
}

internal class InsertDeleteTableViewDataSource: TableViewDataSource {

    typealias CanEditRowAtIndexPath = (UITableView, NSIndexPath) -> Bool
    typealias CommitEditingStyleForRowAtIndexPath = (UITableView, UITableViewCellEditingStyle, NSIndexPath) -> Void

    let canEditRowAtIndexPath: CanEditRowAtIndexPath
    let commitEditingStyleForRowAtIndexPath: CommitEditingStyleForRowAtIndexPath

    init(tableViewDataSource: TableViewDataSource, canEditRowAtIndexPath: CanEditRowAtIndexPath, commitEditingStyleForRowAtIndexPath: CommitEditingStyleForRowAtIndexPath) {

        self.canEditRowAtIndexPath = canEditRowAtIndexPath
        self.commitEditingStyleForRowAtIndexPath = commitEditingStyleForRowAtIndexPath
        super.init(numberOfSections: tableViewDataSource.numberOfSections, numberOfRowsInSection: tableViewDataSource.numberOfRowsInSection, cellForRowAtIndexPath: tableViewDataSource.cellForRowAtIndexPath, titleForHeaderInSection: tableViewDataSource.titleForHeaderInSection, titleForFooterInSection: tableViewDataSource.titleForFooterInSection)
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return canEditRowAtIndexPath(tableView, indexPath)
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        commitEditingStyleForRowAtIndexPath(tableView, editingStyle, indexPath)
    }
}

internal class EditableTableViewDataSource: InsertDeleteTableViewDataSource {

    typealias CanMoveRowAtIndexPath = (UITableView, NSIndexPath) -> Bool
    typealias MoveRowAtIndexPathToIndexPath = (UITableView, NSIndexPath, NSIndexPath) -> Void

    let canMoveRowAtIndexPath: CanMoveRowAtIndexPath
    let moveRowAtIndexPathToIndexPath: MoveRowAtIndexPathToIndexPath

    init(insertDeleteTableViewDataSource edit: InsertDeleteTableViewDataSource, canMoveRowAtIndexPath: CanMoveRowAtIndexPath, moveRowAtIndexPathToIndexPath: MoveRowAtIndexPathToIndexPath) {
        self.canMoveRowAtIndexPath = canMoveRowAtIndexPath
        self.moveRowAtIndexPathToIndexPath = moveRowAtIndexPathToIndexPath
        super.init(tableViewDataSource: edit, canEditRowAtIndexPath: edit.canEditRowAtIndexPath, commitEditingStyleForRowAtIndexPath: edit.commitEditingStyleForRowAtIndexPath)
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return canMoveRowAtIndexPath(tableView, indexPath)
    }

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        moveRowAtIndexPathToIndexPath(tableView, sourceIndexPath, destinationIndexPath)
    }
}

internal enum BridgedTableViewDataSource: UITableViewDataSourceProvider {
    case Readonly(TableViewDataSource)
    case InsertDelete(InsertDeleteTableViewDataSource)
    case Editable(EditableTableViewDataSource)

    var tableViewDataSource: UITableViewDataSource {
        switch self {
        case .Readonly(let readonly):
            return readonly
        case .InsertDelete(let insertDelete):
            return insertDelete
        case .Editable(let editable):
            return editable
        }
    }

    func addInsertDeleteCapability(editor: DataSourceEditorType) -> BridgedTableViewDataSource {
        guard editor.capability.contains(Edit.Capability.InsertDelete), case let .Readonly(readonly) = self else { return self }

        let insertDeleteTableViewDataSource = InsertDeleteTableViewDataSource(
            tableViewDataSource: readonly,
            canEditRowAtIndexPath: { [unowned editor] _, indexPath in
                editor.canEditItemAtIndexPath!(indexPath: indexPath)
            },
            commitEditingStyleForRowAtIndexPath: { [unowned editor] _, editingStyle, indexPath in
                if let action = Edit.Action(rawValue: editingStyle) {
                    editor.commitEditActionForItemAtIndexPath?(action: action, indexPath: indexPath)
                }
            }
        )

        return .InsertDelete(insertDeleteTableViewDataSource)
    }

    func addFullEditableCapability(editor: DataSourceEditorType) -> BridgedTableViewDataSource {
        guard editor.capability.contains(Edit.Capability.InsertDelete), case let .InsertDelete(insertDelete) = self else { return self }

        let editableTableViewDataSource = EditableTableViewDataSource(
            insertDeleteTableViewDataSource: insertDelete,
            canMoveRowAtIndexPath: { [unowned editor] _, indexPath in
                editor.canMoveItemAtIndexPath!(indexPath: indexPath)
            },
            moveRowAtIndexPathToIndexPath: { [unowned editor] _, from, to in
                editor.moveItemAtIndexPathToIndexPath?(from: from, to: to)
            }
        )

        return .Editable(editableTableViewDataSource)
    }
}

internal extension CellDataSourceType {

    var numberOfSectionsInTableView: TableViewDataSource.NumberOfSections {
        return { [unowned self] _ in self.numberOfSections }
    }

    var numberOfRowsInSectionInTableView: TableViewDataSource.NumberOfRowsInSection {
        return { [unowned self] _, section in self.numberOfItemsInSection(section) }
    }
}

internal extension CellDataSourceType where Factory.View: TableViewType, Factory.Cell: UITableViewCell, Factory.CellIndex.ViewIndex == NSIndexPath {

    var cellForRowAtIndexPathInTableView: TableViewDataSource.CellForRowAtIndexPath {
        return { [unowned self] (tableView: UITableView, indexPath: NSIndexPath) in
            return try self.cellForItemInView(tableView as! Factory.View, atIndex: indexPath) as UITableViewCell
        }
    }
}

internal extension CellDataSourceType where Factory.View: TableViewType, Factory.SupplementaryIndex.ViewIndex == Int, Factory.Text == String {

    var titleForHeaderInSectionInTableView: TableViewDataSource.TitleInSection {
        return { [unowned self] (tableView: UITableView, section: Int) in
            return self.supplementaryTextForElementKind(.Header, inView: tableView as! Factory.View, atIndex: section)
        }
    }

    var titleForFooterInSectionInTableView: TableViewDataSource.TitleInSection {
        return { [unowned self] (tableView: UITableView, section: Int) in
            return self.supplementaryTextForElementKind(.Footer, inView: tableView as! Factory.View, atIndex: section)
        }
    }
}



