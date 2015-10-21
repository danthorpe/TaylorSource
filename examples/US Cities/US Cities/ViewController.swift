//
//  ViewController.swift
//  US Cities
//
//  Created by Daniel Thorpe on 10/05/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import YapDatabase
import YapDatabaseExtensions
import TaylorSource

class CityCell: UITableViewCell {

    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Value1, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func configuration(formatter: NSNumberFormatter) -> CitiesDatasource.Datasource.FactoryType.CellConfiguration {
        return { (cell, city, index) in
            cell.textLabel!.font = UIFont.preferredFontForTextStyle(city.capital ? UIFontTextStyleHeadline : UIFontTextStyleBody)
            cell.textLabel!.text = city.name
            cell.detailTextLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            cell.detailTextLabel!.text = formatter.stringFromNumber(NSNumber(integer: city.population))
        }
    }
}

struct CitiesDatasource: DatasourceProviderType {
    typealias Factory = YapDBFactory<City, CityCell, UITableViewHeaderFooterView, UITableView>
    typealias Datasource = YapDBDatasource<Factory>

    let readWriteConnection: YapDatabaseConnection
    let formatter: NSNumberFormatter
    let editor = NoEditor()
    var datasource: Datasource

    init(db: YapDatabase, view: Factory.ViewType, threshold: Int) {

        formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.perMillSymbol = ","
        formatter.allowsFloats = false

        readWriteConnection = db.newConnection()

        datasource = Datasource(id: "cities datasource", database: db, factory: Factory(), processChanges: view.processChanges, configuration: City.cities(abovePopulationThreshold: threshold))

        datasource.factory.registerCell(.ClassWithIdentifier(CityCell.self, "cell"), inView: view, configuration: CityCell.configuration(formatter))
        datasource.factory.registerHeaderText { index in
            if let state: State = index.transaction.readByKey(index.group) {
                return state.name
            }
            return .None
        }
    }

    func addCity(city: City, toState state: State) {
        readWriteConnection.readWriteWithBlock { transaction in
            transaction.write(state)
            transaction.write(city)
        }
    }
}

class ViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet var tableViewHeader: UIView!

    lazy var data = USStatesAndCities()
    var wrapper: TableViewDataSourceProvider<CitiesDatasource>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Some US Cities & States", comment: "Some US Cities & States")
        configureDatasource()
    }

    func configureDatasource() {
        wrapper = TableViewDataSourceProvider(CitiesDatasource(db: database, view: tableView, threshold: 20_000))
        tableView.dataSource = wrapper.tableViewDataSource
        tableView.tableHeaderView = tableViewHeader
        data.loadIntoDatabase(database)
    }
}

// MARK: - Dataloader

struct USStatesAndCities {
    let data: NSDictionary

    init() {
        let path = NSBundle.mainBundle().pathForResource("USStatesAndCities", ofType: "plist")
        data = NSDictionary(contentsOfFile: path!)!
    }

    func cityDataForState(stateName: String) -> [NSDictionary] {
        return (data[stateName] as! NSDictionary)["StateCities"] as! [NSDictionary]
    }

    func loadIntoDatabase(db: YapDatabase) {

        let connection = db.newConnection()

        let states: [State] = connection.readAll()
        let stateNames = states.map { $0.name }
        let remainingStateNames = (data.allKeys as! [String]).filter { !stateNames.contains($0) }

        for stateName in remainingStateNames {

            let state = State(name: stateName)
            let cities = cityDataForState(stateName).map { (cityData: NSDictionary) -> City in
                let cityName = cityData["CityName"] as! String
                let population = (cityData["CityPopulation"] as! NSNumber).integerValue
                let isCapital = (cityData["isCapital"] as? NSNumber)?.boolValue ?? false
                return City(name: cityName, population: population, capital: isCapital, stateId: state.identifier)
            }

            connection.asyncWrite(state) { _ in
                connection.asyncWrite(cities) { _ in
                    print("Wrote \(state.name) cities to database.")
                }
            }
        }
    }
}

