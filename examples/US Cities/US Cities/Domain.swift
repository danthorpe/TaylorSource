//
//  Domain.swift
//  US Cities
//
//  Created by Daniel Thorpe on 10/05/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import YapDatabase
import ValueCoding
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

extension City {

    static let view: YapDB.Fetch = {

        let grouping: YapDB.View.Grouping = .ByObject({ (_, collection, key, object) -> String! in
            if collection == City.collection, let city = City.decode(object) {
                return collection
            }
            return nil
        })

        let sorting: YapDB.View.Sorting = .ByObject({ (_, group, collection1, key1, object1, collection2, key2, object2) -> NSComparisonResult in
            if let city1 = City.decode(object1), city2 = City.decode(object2) {
                return city1.compare(city2)
            }
            return .OrderedSame
        })

        return .View(YapDB.View(name: "Cities", grouping: grouping, sorting: sorting, collections: [collection]))
    }()

    static let viewByState: YapDB.Fetch = {

        let grouping: YapDB.View.Grouping = .ByObject({ (_, collection, key, object) -> String! in
            if collection == City.collection, let city = City.decode(object) {
                return city.stateId
            }
            return nil
        })

        let sorting: YapDB.View.Sorting = .ByObject({ (_, group, collection1, key1, object1, collection2, key2, object2) -> NSComparisonResult in
            if let city1 = City.decode(object1), city2 = City.decode(object2) {
                return city1.compare(city2)
            }
            return .OrderedSame
        })

        return .View(YapDB.View(name: "Cities by State ID", grouping: grouping, sorting: sorting, collections: [collection]))
    }()

    static func viewCities(byState: Bool = true, abovePopulationThreshold threshold: Int = 0) -> YapDB.Fetch {
        let parent = byState ? viewByState : view
        if threshold > 0 {

            let filtering = YapDB.Filter.Filtering.ByObject({ (_, group, collection, key, object) -> Bool in
                if collection == City.collection, let city = City.decode(object) {
                    return city.population >= threshold
                }
                return false
            })

            let name = "\(parent.name), above population threshold: \(threshold)"
            return .Filter(YapDB.Filter(name: name, parent: parent, filtering: filtering, collections: [collection]))
        }
        return parent
    }

    static func cities(byState: Bool = true, abovePopulationThreshold threshold: Int = 0, mappingBlock: YapDB.FetchConfiguration.MappingsConfigurationBlock? = .None) -> TaylorSource.Configuration<City> {
        let config = YapDB.FetchConfiguration(fetch: viewCities(byState, abovePopulationThreshold: threshold), block: mappingBlock)
        return TaylorSource.Configuration(fetch: config, itemMapper: City.decode)
    }






}

// MARK: - Persistable

extension State: Persistable {

    static let collection: String = "States"

    var identifier: Identifier {
        return name
    }
}


extension City: Persistable {

    static let collection: String = "Cities"

    var identifier: Identifier {
        return name
    }
}

// MARK: - Equatable 

extension State: Equatable { }

func ==(a: State, b: State) -> Bool {
    return a.name == b.name
}

extension City: Equatable { }

func ==(a: City, b: City) -> Bool {
    return (a.name == b.name) && (a.population == b.population) && (a.capital == b.capital) && (a.stateId == b.stateId)
}

// MARK: - Comparable

extension City: Comparable {

    func compare(other: City) -> NSComparisonResult {
        if self == other {
            return .OrderedSame
        }
        else if self < other {
            return .OrderedAscending
        }
        return .OrderedDescending
    }
}

func <(a: City, b: City) -> Bool {
    switch (a.capital, b.capital) {
    case (true, false):
        return true
    case (false, true):
        return false
    default:
        if a.population == b.population {
            return a.name < b.name
        }
        return a.population < b.population
    }
}


// MARK: - ValueCoding

extension State: ValueCoding {
    typealias Coder = StateCoder
}

extension City: ValueCoding {
    typealias Coder = CityCoder
}

// MARK: - Coders

class StateCoder: NSObject, NSCoding, CodingType {

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

class CityCoder: NSObject, NSCoding, CodingType {

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

