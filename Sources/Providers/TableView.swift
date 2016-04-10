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
    typealias Index = NSIndexPath
}

public struct TableViewDataSourceProvider<
    DataSourceProvider
    where
    DataSourceProvider: DataSourceProviderType,
    DataSourceProvider.DataSource: CellDataSourceType,
    DataSourceProvider.DataSource.Factory.View: TableViewType,
    DataSourceProvider.DataSource.Factory.Cell: UITableViewCell,
    DataSourceProvider.DataSource.Factory.CellIndex.ViewIndex == NSIndexPath,
    DataSourceProvider.DataSource.Factory.SupplementaryIndex.ViewIndex == Int,
    DataSourceProvider.DataSource.Factory.Text == String> {

    typealias TableView = DataSource.Factory.View

    public let provider: DataSourceProvider

    private let bridgedTableViewDataSource: BridgedTableViewDataSource

    public init(_ provider: DataSourceProvider) {
        self.provider = provider

        let basicTableViewDataSource = BasicTableViewDataSource(
            numberOfSections: provider.dataSource.numberOfSections,
            numberOfRowsInSection: provider.dataSource.numberOfRowsInSection,
            cellForRowAtIndexPath: provider.dataSource.cellForRowAtIndexPath,
            titleForHeaderInSection: provider.dataSource.titleForHeaderInSection,
            titleForFooterInSection: provider.dataSource.titleForFooterInSection)

        self.bridgedTableViewDataSource = .Readonly(basicTableViewDataSource)
    }
}

extension TableViewDataSourceProvider: DataSourceProviderType {

    public typealias DataSource = DataSourceProvider.DataSource
    public typealias Editor = DataSourceProvider.Editor

    public var dataSource: DataSource {
        return provider.dataSource
    }

    public var editor: Editor {
        return provider.editor
    }
}


internal class BasicTableViewDataSource: NSObject, UITableViewDataSource {

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

internal extension CellDataSourceType {

    var numberOfSections: BasicTableViewDataSource.NumberOfSections {
        return { [unowned self] _ in self.numberOfSections }
    }

    var numberOfRowsInSection: BasicTableViewDataSource.NumberOfRowsInSection {
        return { [unowned self] _, section in self.numberOfItemsInSection(section) }
    }
}

internal extension CellDataSourceType where Factory.View: TableViewType, Factory.Cell: UITableViewCell, Factory.CellIndex.ViewIndex == NSIndexPath {

    var cellForRowAtIndexPath: BasicTableViewDataSource.CellForRowAtIndexPath {
        return { [unowned self] (tableView: UITableView, indexPath: NSIndexPath) in
            return try self.cellForItemInView(tableView as! Factory.View, atIndex: indexPath) as UITableViewCell
        }
    }
}

internal extension CellDataSourceType where Factory.View: TableViewType, Factory.SupplementaryIndex.ViewIndex == Int, Factory.Text == String {

    var titleForHeaderInSection: BasicTableViewDataSource.TitleInSection {
        return { [unowned self] (tableView: UITableView, section: Int) in
            return self.supplementaryTextForElementKind(.Header, inView: tableView as! Factory.View, atIndex: section)
        }
    }

    var titleForFooterInSection: BasicTableViewDataSource.TitleInSection {
        return { [unowned self] (tableView: UITableView, section: Int) in
            return self.supplementaryTextForElementKind(.Footer, inView: tableView as! Factory.View, atIndex: section)
        }
    }
}



internal enum BridgedTableViewDataSource: UITableViewDataSourceProvider {
    case Readonly(BasicTableViewDataSource)

    var tableViewDataSource: UITableViewDataSource {
        switch self {
        case .Readonly(let readonly):
            return readonly
        }
    }
}


