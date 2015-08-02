//
//  Created by Daniel Thorpe on 16/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import DateTools
import YapDatabase
import YapDatabaseExtensions
import TaylorSource

extension Event.Color {
    var uicolor: UIColor {
        switch self {
        case .Red: return UIColor.redColor()
        case .Blue: return UIColor.blueColor()
        case .Green: return UIColor.greenColor()
        }
    }
}

class EventCell: UITableViewCell {
    class func configuration() -> EventsDatasource.Datasource.FactoryType.CellConfiguration {
        return { (cell, event, index) in
            cell.textLabel!.text = "\(event.date.timeAgoSinceNow())"
            cell.textLabel!.textColor = event.color.uicolor
        }
    }
}

struct EventsDatasource: DatasourceProviderType {

    typealias Factory = YapDBFactory<Event, EventCell, UITableViewHeaderFooterView, UITableView>
    typealias Datasource = YapDBDatasource<Factory>

    let readWriteConnection: YapDatabaseConnection
    let eventColor: Event.Color
    let datasource: Datasource

    var canEditItemAtIndexPath: CanEditItemAtIndexPath? {
        return { _ in true }
    }

    var commitEditActionForItemAtIndexPath: CommitEditActionForItemAtIndexPath? {
        return { (action, indexPath) in
            switch action {
            case .Delete:
                if let item = self.datasource.itemAtIndexPath(indexPath) {
                    self.readWriteConnection.remove(item)
                }
            default: break
            }
        }
    }

    var editActionForItemAtIndexPath: EditActionForItemAtIndexPath? {
        return { _ in .Delete }
    }

    var canMoveItemAtIndexPath: CanMoveItemAtIndexPath? {
        return { _ in false }
    }

    var commitMoveItemAtIndexPathToIndexPath: CommitMoveItemAtIndexPathToIndexPath? {
        return { (_, _) in }
    }

    init(color: Event.Color, db: YapDatabase, view: Factory.ViewType) {

        var ds = YapDBDatasource(id: "\(color) events datasource", database: db, factory: Factory(), processChanges: view.processChanges, configuration: eventsWithColor(color, byColor: true) { mappings in
            mappings.setIsReversed(true, forGroup: "\(color)")
        })

        ds.title = color.description

        eventColor = color
        readWriteConnection = db.newConnection()
        datasource = ds
        datasource.factory.registerCell(.ClassWithIdentifier(EventCell.self, "cell"), inView: view, configuration: EventCell.configuration())
    }

    func addEvent(event: Event) {
        readWriteConnection.write(event)
    }

    func removeAllEvents() {
        readWriteConnection.remove(datasource)
    }
}

class ViewController: UIViewController, UITableViewDelegate {

    typealias TableViewDataSource = TableViewDataSourceProvider<SegmentedDatasourceProvider<EventsDatasource>>

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var wrapper: TableViewDataSource!

    var selectedDatasourceProvider: EventsDatasource {
        return wrapper.provider.selectedDatasourceProvider
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatasource()
    }

    func configureDatasource() {
        let colors: [Event.Color] = [.Red, .Blue, .Green]
        let datasources = colors.map { EventsDatasource(color: $0, db: database, view: self.tableView) }

        wrapper = TableViewDataSource(SegmentedDatasourceProvider(id: "events segmented datasource", datasources: datasources, selectedIndex: 0) { [weak self] in
            self?.tableView.reloadData()
        })
        wrapper.provider.configureSegmentedControl(segmentedControl)
        tableView.dataSource = wrapper.tableViewDataSource
        tableView.setEditing(true, animated: false)
    }

    @IBAction func addEvent(sender: UIBarButtonItem) {
        let color = selectedDatasourceProvider.eventColor
        selectedDatasourceProvider.addEvent(Event.create(color: color))
    }

    @IBAction func refreshEvents(sender: UIBarButtonItem) {
        tableView.reloadData()
    }

    @IBAction func removeAll(sender: UIBarButtonItem) {
        selectedDatasourceProvider.removeAllEvents()
    }

    // UITableViewDelegate - Editing

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return selectedDatasourceProvider.editActionForItemAtIndexPath?(indexPath: indexPath).editingStyle ?? .None
    }
}

