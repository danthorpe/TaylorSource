//
//  DatasourceProviderTests.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 13/07/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import XCTest
import TaylorSource

class DatasourceProviderTests: XCTestCase {

    struct EditableEventDatasourceProvider: DatasourceProviderType {
        typealias Factory = BasicFactory<Event, UITableViewCell, UITableViewHeaderFooterView, StubbedTableView>
        typealias Datasource = StaticDatasource<Factory>

        let datasource: Datasource
        let canEditItemAtIndexPath: CanEditItemAtIndexPath?
        let commitEditActionForItemAtIndexPath: CommitEditActionForItemAtIndexPath?
        let canMoveItemAtIndexPath: CanMoveItemAtIndexPath?
        let commitMoveItemAtIndexPathToIndexPath: CommitMoveItemAtIndexPathToIndexPath?

        let editActionForItemAtIndexPath: EditActionForItemAtIndexPath?

        init(
            data: [Event],
            canEdit: CanEditItemAtIndexPath? = .None,
            commitEdit: CommitEditActionForItemAtIndexPath? = .None,
            canMove: CanMoveItemAtIndexPath? = .None,
            commitMove: CommitMoveItemAtIndexPathToIndexPath? = .None,
            editAction: EditActionForItemAtIndexPath? = .None) {

                datasource = Datasource(id: "test", factory: Factory(), items: data)

                canEditItemAtIndexPath = canEdit
                commitEditActionForItemAtIndexPath = commitEdit
                canMoveItemAtIndexPath = canMove
                commitMoveItemAtIndexPathToIndexPath = commitMove
                editActionForItemAtIndexPath = editAction
        }
    }

    let data: [Event] = map(0..<5) { (index) -> Event in Event.create() }
    var wrapper: TableViewDataSourceProvider<EditableEventDatasourceProvider>!


    // MARK: - Editing

    func test__EditableDatasourceAction__vs__UITableViewCellEditingStyle() {
        XCTAssertEqual(EditableDatasourceAction(editingStyle: .None)!.editingStyle, UITableViewCellEditingStyle.None)
        XCTAssertEqual(EditableDatasourceAction(editingStyle: .Insert)!.editingStyle, UITableViewCellEditingStyle.Insert)
        XCTAssertEqual(EditableDatasourceAction(editingStyle: .Delete)!.editingStyle, UITableViewCellEditingStyle.Delete)
    }


    func test__provider_with_no_edit_closures__table_view_datasource_is_readonly() {
        wrapper = TableViewDataSourceProvider(EditableEventDatasourceProvider(data: data))
        let tableViewDataSource = wrapper.tableViewDataSource
        assertTableViewDataSourceImplementsBaseMethods(tableViewDataSource)
        XCTAssertFalse(tableViewDataSource.respondsToSelector("tableView:canEditRowAtIndexPath:"))
        XCTAssertFalse(tableViewDataSource.respondsToSelector("tableView:commitEditingStyle:forRowAtIndexPath:"))
        XCTAssertFalse(tableViewDataSource.respondsToSelector("tableView:canMoveRowAtIndexPath:"))
        XCTAssertFalse(tableViewDataSource.respondsToSelector("tableView:moveRowAtIndexPath:toIndexPath:"))

    }

    func test__provider_with_edit_closures__table_view_datasource_is_editable() {
        wrapper = TableViewDataSourceProvider(EditableEventDatasourceProvider(
            data: data,
            canEdit: { _ in return true },
            commitEdit: { (_, _) in },
            canMove: { _ in return true },
            commitMove: { (_, _) in },
            editAction: { _ in return .Delete }))

        let tableViewDataSource = wrapper.tableViewDataSource
        assertTableViewDataSourceImplementsBaseMethods(tableViewDataSource)
        XCTAssertTrue(tableViewDataSource.respondsToSelector("tableView:canEditRowAtIndexPath:"))
        XCTAssertTrue(tableViewDataSource.respondsToSelector("tableView:commitEditingStyle:forRowAtIndexPath:"))
        XCTAssertTrue(tableViewDataSource.respondsToSelector("tableView:canMoveRowAtIndexPath:"))
        XCTAssertTrue(tableViewDataSource.respondsToSelector("tableView:moveRowAtIndexPath:toIndexPath:"))
    }

    func test__editable_provider__receives_calls_for__can_edit() {

        var canEditIndexPath: NSIndexPath? = nil

        wrapper = TableViewDataSourceProvider(EditableEventDatasourceProvider(
            data: data,
            canEdit: { indexPath in
                canEditIndexPath = indexPath
                return true
            },
            commitEdit: { (_, _) in },
            canMove: { _ in return true },
            commitMove: { (_, _) in },
            editAction: { _ in return .Delete }))

        let tableViewDataSource = wrapper.tableViewDataSource
        let view = StubbedTableView()

        tableViewDataSource.tableView?(view, canEditRowAtIndexPath: NSIndexPath.first)

        XCTAssertNotNil(canEditIndexPath)
        XCTAssertEqual(canEditIndexPath!, NSIndexPath.first)
    }

    func test__editable_provider__receives_calls_for__commit_edit() {

        var commitEditAction: EditableDatasourceAction? = nil
        var commitEditIndexPath: NSIndexPath? = nil

        wrapper = TableViewDataSourceProvider(EditableEventDatasourceProvider(
            data: data,
            canEdit: { _ in return true },
            commitEdit: { (action, indexPath) in
                commitEditAction = action
                commitEditIndexPath = indexPath
            },
            canMove: { _ in return true },
            commitMove: { (_, _) in },
            editAction: { _ in return .Delete }))

        let tableViewDataSource = wrapper.tableViewDataSource
        let view = StubbedTableView()

        tableViewDataSource.tableView?(view, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath.first)

        XCTAssertNotNil(commitEditIndexPath)
        XCTAssertEqual(commitEditIndexPath!, NSIndexPath.first)

        XCTAssertTrue(commitEditAction != nil)
        XCTAssertEqual(commitEditAction!, EditableDatasourceAction.Delete)
    }

    func test__editable_provider__receives_calls_for__can_move() {

        var canMoveIndexPath: NSIndexPath? = nil

        wrapper = TableViewDataSourceProvider(EditableEventDatasourceProvider(
            data: data,
            canEdit: { _ in return true },
            commitEdit: { (_, _) in },
            canMove: { indexPath in
                canMoveIndexPath = indexPath
                return true },
            commitMove: { (_, _) in },
            editAction: { _ in return .Delete }))

        let tableViewDataSource = wrapper.tableViewDataSource
        let view = StubbedTableView()

        tableViewDataSource.tableView?(view, canMoveRowAtIndexPath: NSIndexPath.first)

        XCTAssertNotNil(canMoveIndexPath)
        XCTAssertEqual(canMoveIndexPath!, NSIndexPath.first)
    }

    func test__editable_provider__receives_calls_for__commit_move() {

        var commitMoveFromIndexPath: NSIndexPath? = nil
        var commitMoveToIndexPath: NSIndexPath? = nil

        wrapper = TableViewDataSourceProvider(EditableEventDatasourceProvider(
            data: data,
            canEdit: { _ in return true },
            commitEdit: { (_, _) in },
            canMove: { _ in return true },
            commitMove: { (from, to) in
                commitMoveFromIndexPath = from
                commitMoveToIndexPath = to
            },
            editAction: { _ in return .Delete }))

        let tableViewDataSource = wrapper.tableViewDataSource
        let view = StubbedTableView()

        let to = NSIndexPath(forRow: 1, inSection: 0)
        tableViewDataSource.tableView?(view, moveRowAtIndexPath: NSIndexPath.first, toIndexPath: to)

        XCTAssertNotNil(commitMoveFromIndexPath)
        XCTAssertEqual(commitMoveFromIndexPath!, NSIndexPath.first)

        XCTAssertNotNil(commitMoveToIndexPath)
        XCTAssertEqual(commitMoveToIndexPath!, to)
    }

    // MARK: - Helpers

    func assertTableViewDataSourceImplementsBaseMethods(tableViewDataSource: UITableViewDataSource) {
        XCTAssertTrue(tableViewDataSource.respondsToSelector("tableView:numberOfRowsInSection:"))
        XCTAssertTrue(tableViewDataSource.respondsToSelector("tableView:cellForRowAtIndexPath:"))
        XCTAssertTrue(tableViewDataSource.respondsToSelector("numberOfSectionsInTableView:"))
    }
}
