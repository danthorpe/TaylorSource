//
//  TableViewTests.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 10/04/2016.
//  Copyright © 2016 Daniel Thorpe. All rights reserved.
//

import XCTest
@testable import TaylorSource

class NoEditorDataSourceProvider<DataSource: DataSourceType>: DataSourceProviderType {

    let dataSource: DataSource
    let editor = NoEditor()

    init(_ dataSource: DataSource) {
        self.dataSource = dataSource
    }
}

class ReadonlyTableViewDataSourceProviderTests: DataSourceTests {

    typealias DataSourceProvider = NoEditorDataSourceProvider<DataSource>

    var dataSourceProvider: DataSourceProvider!
    var tableViewDataSourceProvider: TableViewDataSourceProvider<DataSourceProvider>!
    var tableViewDataSource: UITableViewDataSource!
    var indexPath: NSIndexPath!

    override func setUp() {
        super.setUp()
        setUpAgain()
    }

    override func tearDown() {
        indexPath = nil
        tableViewDataSource = nil
        tableViewDataSourceProvider = nil
        dataSourceProvider = nil
        super.tearDown()
    }

    func setUpAgain() {
        dataSourceProvider = NoEditorDataSourceProvider(dataSource)
        tableViewDataSourceProvider = TableViewDataSourceProvider(dataSourceProvider)
        tableViewDataSource = tableViewDataSourceProvider.tableViewDataSource
        indexPath = NSIndexPath(forRow: 0, inSection: 0)
    }

    func test__provider_dataSource_is_dataSource() {
        XCTAssertNotNil(dataSource.identifier)
        XCTAssertEqual(tableViewDataSourceProvider.dataSource.identifier ?? "Not Correct", dataSource.identifier)
    }

    func test__numberOfSectionsInTableView() {
        XCTAssertEqual(tableViewDataSource.numberOfSectionsInTableView?(tableView) ?? 0, 1)
    }

    func test__numberOfRowsInSection() {
        XCTAssertEqual(tableViewDataSource.tableView(tableView, numberOfRowsInSection: 0), 2)
    }

    func test__cellForRowAtIndexPath() {

        var didConfigureCellWithItemAtIndex: (Cell, Item, NSIndexPath)? = .None
        factory.registerCell(.ClassWithIdentifier(Cell.self, "cell identifier"), inView: tableView) { cell, item, index in
            didConfigureCellWithItemAtIndex = (cell, item, index)
        }
        setUpAgain()

        let _ = tableViewDataSource.tableView(tableView, cellForRowAtIndexPath: indexPath)

        guard let (_, item, index) = didConfigureCellWithItemAtIndex else {
            XCTFail("Did not configure cell"); return
        }

        XCTAssertEqual(item, "Hello")
        XCTAssertEqual(indexPath, index)
    }

    func test__titleForHeaderInSection() {

        var didConfigureSupplementaryText: Int? = .None
        factory.registerSupplementaryTextWithKind(.Header) { section in
            didConfigureSupplementaryText = section
            return "Header text with index: \(section)"
        }

        setUpAgain()

        let index = 0
        let text = tableViewDataSource.tableView?(tableView, titleForHeaderInSection: index)

        guard let section = didConfigureSupplementaryText else {
            XCTFail("Did not configure cell"); return
        }

        XCTAssertNotNil(text)
        XCTAssertEqual(text, "Header text with index: 0")
        XCTAssertEqual(section, index)
    }

    func test__titleForFooterInSection() {

        var didConfigureSupplementaryText: Int? = .None
        factory.registerSupplementaryTextWithKind(.Footer) { section in
            didConfigureSupplementaryText = section
            return "Footer text with index: \(section)"
        }

        setUpAgain()

        let index = 0
        let text = tableViewDataSource.tableView?(tableView, titleForFooterInSection: 0)

        guard let section = didConfigureSupplementaryText else {
            XCTFail("Did not configure cell"); return
        }

        XCTAssertNotNil(text)
        XCTAssertEqual(text, "Footer text with index: 0")
        XCTAssertEqual(section, index)
    }
}

class EditableDataSourceProvider<DataSource: DataSourceType>: DataSourceProviderType {

    let dataSource: DataSource
    let editor: Editor

    init(_ dataSource: DataSource, editor: Editor) {
        self.dataSource = dataSource
        self.editor = editor
    }
}

class InsertDeleteTableViewDataSourceProviderTests: DataSourceTests {

    typealias DataSourceProvider = EditableDataSourceProvider<DataSource>

    var editor: Editor!
    var dataSourceProvider: DataSourceProvider!
    var tableViewDataSourceProvider: TableViewDataSourceProvider<DataSourceProvider>!
    var tableViewDataSource: UITableViewDataSource!
    var indexPath: NSIndexPath!

    var didCheckCanEditAtIndexPath: NSIndexPath? = .None
    var didCommitEditActionAtIndexPath: (Edit.Action, NSIndexPath)? = .None

    override func setUp() {
        super.setUp()
        setUpAgain()
    }

    override func tearDown() {
        indexPath = nil
        tableViewDataSource = nil
        tableViewDataSourceProvider = nil
        dataSourceProvider = nil
        super.tearDown()
    }

    func setUpAgain() {
        editor = Editor(
            canEdit: { [unowned self] indexPath in
                self.didCheckCanEditAtIndexPath = indexPath
                return true
            },
            commitEdit: { [unowned self] action, indexPath in
                self.didCommitEditActionAtIndexPath = (action, indexPath)
            },
            editAction: { _ in .Insert },
            canMove: .None, move: .None)
        dataSourceProvider = EditableDataSourceProvider(dataSource, editor: editor)
        tableViewDataSourceProvider = TableViewDataSourceProvider(dataSourceProvider)
        tableViewDataSource = tableViewDataSourceProvider.tableViewDataSource
        indexPath = NSIndexPath(forRow: 0, inSection: 0)
    }

    func test__canEditRowAtIndexPath() {
        XCTAssertTrue(tableViewDataSource.tableView?(tableView, canEditRowAtIndexPath: indexPath) ?? false)
        XCTAssertEqual(didCheckCanEditAtIndexPath ?? NSIndexPath(forRow: 1, inSection: 1), indexPath)
    }

    func test__commitEditingStyleForRowAtIndexPath() {
        tableViewDataSource.tableView?(tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
        guard let (action, index) = didCommitEditActionAtIndexPath else {
            XCTFail("Did not commit editing."); return
        }

        XCTAssertEqual(action, Edit.Action.Delete)
        XCTAssertEqual(index, indexPath)
    }
}

class EditableTableViewDataSourceProviderTests: DataSourceTests {

    typealias DataSourceProvider = EditableDataSourceProvider<DataSource>

    var editor: Editor!
    var dataSourceProvider: DataSourceProvider!
    var tableViewDataSourceProvider: TableViewDataSourceProvider<DataSourceProvider>!
    var tableViewDataSource: UITableViewDataSource!
    var indexPath: NSIndexPath!

    var didCheckCanMoveAtIndexPath: NSIndexPath? = .None
    var didMoveIndexPathToIndexPath: (NSIndexPath, NSIndexPath)? = .None

    override func setUp() {
        super.setUp()
        setUpAgain()
    }

    override func tearDown() {
        indexPath = nil
        tableViewDataSource = nil
        tableViewDataSourceProvider = nil
        dataSourceProvider = nil
        super.tearDown()
    }

    func setUpAgain() {
        editor = Editor(
            canEdit: { _ in true },
            commitEdit: { _, _ in },
            editAction: { _ in .Insert },
            canMove: .None,
            move: .None)

        editor = Editor(
            canEdit: { _ in true },
            commitEdit: { _, _ in },
            editAction: { _ in .Insert },
            canMove: { [unowned self] indexPath in
                self.didCheckCanMoveAtIndexPath = indexPath
                return true
            },
            move: { [unowned self] from, to in
                self.didMoveIndexPathToIndexPath = (from, to)
            })
        dataSourceProvider = EditableDataSourceProvider(dataSource, editor: editor)
        tableViewDataSourceProvider = TableViewDataSourceProvider(dataSourceProvider)
        tableViewDataSource = tableViewDataSourceProvider.tableViewDataSource
        indexPath = NSIndexPath(forRow: 0, inSection: 0)
    }

    func test__canMoveRowAtIndexPath() {
        XCTAssertTrue(tableViewDataSource.tableView?(tableView, canMoveRowAtIndexPath: indexPath) ?? false)
        XCTAssertEqual(didCheckCanMoveAtIndexPath ?? NSIndexPath(forRow: 1, inSection: 1), indexPath)
    }

    func test__moveRowAtIndexPathToIndexPath() {
        tableViewDataSource.tableView?(tableView, moveRowAtIndexPath: indexPath, toIndexPath: NSIndexPath(forRow: 1, inSection: 0))
        guard let (from, to) = didMoveIndexPathToIndexPath else {
            XCTFail("Did not move row."); return
        }

        XCTAssertEqual(from, indexPath)
        XCTAssertEqual(to, NSIndexPath(forRow: 1, inSection: 0))
    }
}


