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
            cell.detailTextLabel!.text = formatter.stringFromNumber(NSNumber(integer: city.population))
        }
    }
}

struct CitiesDatasource: DatasourceProviderType {
    typealias Factory = YapDBFactory<City, CityCell, UITableViewHeaderFooterView, UITableView>
    typealias Datasource = YapDBDatasource<Factory>

    let readWriteConnection: YapDatabaseConnection
    let datasource: Datasource
    let formatter: NSNumberFormatter

    init(db: YapDatabase, view: Factory.ViewType) {

        formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.perMillSymbol = ","
        formatter.allowsFloats = false

        readWriteConnection = db.newConnection()

        datasource = Datasource(id: "cities datasource", database: db, factory: Factory(), processChanges: view.processChanges, configuration: cities { mappings in

        })

        datasource.factory.registerCell(.ClassWithIdentifier(CityCell.self, "cell"), inView: view, configuration: CityCell.configuration(formatter))
        datasource.factory.registerHeaderText { index in
            if let state: State = index.transaction.read(index.group) {
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


struct USStatesAndCities {
    let data: NSDictionary

    init() {
        let path = NSBundle.mainBundle().pathForResource("USStatesAndCities", ofType: "plist")
        data = NSDictionary(contentsOfFile: path!)!
    }

    func randomCity() -> (State, City) {
        let states = data.allKeys
        var randomIndex = Int(arc4random()) % states.count
        let stateData = data[states[randomIndex] as! String] as! NSDictionary
        let stateCities = stateData["StateCities"] as! [NSDictionary]
        randomIndex = Int(arc4random()) % stateCities.count
        let cityData = stateCities[randomIndex]
        let state = State(name: stateData["StateName"] as! String)

        let population = (cityData["CityPopulation"] as! NSNumber).integerValue
        let isCapital = (cityData["isCapital"] as? NSNumber)?.boolValue ?? false

        let city = City(name: cityData["CityName"] as! String, population: population, capital: isCapital, stateId: state.identifier)

        return (state, city)
    }
}

class ViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!

    lazy var data = USStatesAndCities()
    var datasource: CitiesDatasource!
    var tableViewDatasource: TableViewDataSourceProvider<CitiesDatasource.Datasource>!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatasource()
    }

    func configureDatasource() {
        datasource = CitiesDatasource(db: database, view: tableView)
        tableViewDatasource = TableViewDataSourceProvider(datasource.datasource)
        tableView.dataSource = tableViewDatasource.tableViewDataSource
    }

    @IBAction func add(sender: AnyObject) {
        let (state, city) = data.randomCity()
        datasource.addCity(city, toState: state)
    }
}

