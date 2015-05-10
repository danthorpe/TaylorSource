//
//  Domain.swift
//  US Cities
//
//  Created by Daniel Thorpe on 10/05/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import YapDatabase
import YapDatabaseExtensions
import TaylorSource

// MARK: - Domain

struct State {
    let name: String
}

struct City {
    let name: String
    let population: Int
    let capital: Bool
    let stateId: Identifier
}

// MARK: - Persistable

extension State: Persistable {

    static var collection: String {
        return "States"
    }

    var identifier: Identifier {
        return name
    }
}


extension City: Persistable {

    static var collection: String {
        return "Cities"
    }

    var identifier: Identifier {
        return name
    }
}

// MARK: - Saveable

extension State: Saveable {

    typealias Archiver = StateArchiver

    var archive: Archiver {
        return Archiver(self)
    }
}

extension City: Saveable {

    typealias Archiver = CityArchiver

    var archive: Archiver {
        return Archiver(self)
    }
}

// MARK: - Archivers

class StateArchiver: NSObject, NSCoding, Archiver {

    let value: State

    required init(_ v: State) {
        value = v
    }

    required init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("name") as? String
        value = State(name: name!)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.name, forKey: "name")
    }
}

class CityArchiver: NSObject, NSCoding, Archiver {

    let value: City

    required init(_ v: City) {
        value = v
    }

    required init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("name") as? String
        let population = aDecoder.decodeIntegerForKey("population")
        let capital = aDecoder.decodeBoolForKey("capital")
        let stateId = aDecoder.decodeObjectForKey("stateId") as? String
        value = City(name: name!, population: population, capital: capital, stateId: stateId!)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.name, forKey: "name")
        aCoder.encodeInteger(value.population, forKey: "population")
        aCoder.encodeBool(value.capital, forKey: "capital")
        aCoder.encodeObject(value.stateId, forKey: "stateId")
    }
}

// MARK: - Database Views

func cities(byState: Bool = true) -> YapDB.Fetch {

    let grouping: YapDB.View.Grouping = .ByObject({(collection, key, object) -> String! in
        if collection == City.collection {
            if byState, let city: City = valueFromArchive(object) {
                return city.stateId
            }
            return collection
        }
        return nil
    })

    let sorting: YapDB.View.Sorting = .ByObject({(group, collection1, key1, object1, collection2, key2, object2) -> NSComparisonResult in
        if let city1: City = valueFromArchive(object1), city2: City = valueFromArchive(object2) {
            switch (city1.capital, city2.capital) {
            case (true, false):
                return .OrderedAscending
            case (false, true):
                return .OrderedDescending
            default:
                switch NSNumber(integer: city1.population).compare(NSNumber(integer: city2.population)) {
                case .OrderedSame:
                    return city1.name.caseInsensitiveCompare(city2.name)
                case let result:
                    return result
                }
            }
        }
        return .OrderedSame
    })

    return .View(YapDB.View(name: "cities", grouping: grouping, sorting: sorting, collections: [City.collection]))
}

func cities(byState: Bool = true, mappingBlock: YapDB.FetchConfiguration.MappingsConfigurationBlock? = .None) -> YapDB.FetchConfiguration {
    return YapDB.FetchConfiguration(fetch: cities(byState: byState), block: mappingBlock)
}

func cities(byState: Bool = true, mappingBlock: YapDB.FetchConfiguration.MappingsConfigurationBlock? = .None) -> TaylorSource.Configuration<City> {
    return TaylorSource.Configuration(fetch: cities(byState: byState, mappingBlock: mappingBlock), itemMapper: valueFromArchive)
}

