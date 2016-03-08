//
//  Models.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 08/03/2016.
//
//

import Foundation
import ValueCoding
import YapDatabaseExtensions
import YapDatabase
@testable import TaylorSource

struct Event {

    enum Color {
        case Red, Blue, Green
    }

    let uuid: String
    let color: Color
    let date: NSDate

    init(uuid: String = NSUUID().UUIDString, color: Color, date: NSDate = NSDate()) {
        self.uuid = uuid
        self.color = color
        self.date = date
    }

    static func create(color color: Color = .Red) -> Event {
        return Event(color: color)
    }
}

extension Event.Color: CustomStringConvertible {

    var description: String {
        switch self {
        case .Red: return "Red"
        case .Blue: return "Blue"
        case .Green: return "Green"
        }
    }
}

extension Event.Color: Equatable { }

func == (lhs: Event.Color, rhs: Event.Color) -> Bool {
    switch (lhs,rhs) {
    case (.Red, .Red), (.Blue, .Blue), (.Green, .Green):
        return true
    default:
        return false
    }
}

extension Event: Equatable { }

func == (lhs: Event, rhs: Event) -> Bool {
    return (lhs.color == rhs.color) && (lhs.uuid == rhs.uuid) && (lhs.date == rhs.date)
}

extension Event.Color: ValueCoding {

    typealias Coder = EventColorCoder

    enum Kind: Int {
        case Red = 1, Blue, Green
    }

    var kind: Kind {
        switch self {
        case .Red: return Kind.Red
        case .Blue: return Kind.Blue
        case .Green: return Kind.Green
        }
    }
}

class EventColorCoder: NSObject, NSCoding, CodingType {

    let value: Event.Color

    required init(_ v: Event.Color) {
        value = v
    }

    required init?(coder aDecoder: NSCoder) {
        if let kind = Event.Color.Kind(rawValue: aDecoder.decodeIntegerForKey("kind")) {
            switch kind {
            case .Red:
                value = Event.Color.Red
            case .Blue:
                value = Event.Color.Blue
            case .Green:
                value = Event.Color.Green
            }
        }
        else { fatalError("Event.Color.Kind not correctly encoded.") }
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(value.kind.rawValue, forKey: "kind")
    }
}

extension Event: Identifiable {
    var identifier: String {
        return uuid
    }
}

extension Event: Persistable {
    static var collection: String {
        return "Events"
    }
}

extension Event: ValueCoding {
    typealias Coder = EventCoder
}

class EventCoder: NSObject, NSCoding, CodingType {

    let value: Event

    required init(_ v: Event) {
        value = v
    }

    required init?(coder aDecoder: NSCoder) {
        let color = Event.Color.decode(aDecoder.decodeObjectForKey("color"))
        let uuid = aDecoder.decodeObjectForKey("uuid") as? String
        let date = aDecoder.decodeObjectForKey("date") as? NSDate
        value = Event(uuid: uuid!, color: color!, date: date!)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.color.encoded, forKey: "color")
        aCoder.encodeObject(value.uuid, forKey: "uuid")
        aCoder.encodeObject(value.date, forKey: "date")
    }
}

func createSomeEvents(numberOfDays: Int = 10) -> [Event] {
    let today = NSDate()
    let interval: NSTimeInterval = 86_400
    return (0..<numberOfDays).map { index in
        let date = today.dateByAddingTimeInterval(-1.0 * Double(index) * interval)
        return Event(color: .Red, date: date)
    }
}

func events(byColor: Bool = false) -> YapDB.Fetch {

    let grouping: YapDB.View.Grouping = .ByObject({ (_, collection, key, object) -> String! in
        if collection == Event.collection {
            if !byColor {
                return collection
            }

            if let event = Event.decode(object) {
                return event.color.description
            }
        }
        return .None
    })

    let sorting: YapDB.View.Sorting = .ByObject({ (_, group, collection1, key1, object1, collection2, key2, object2) -> NSComparisonResult in
        if  let event1 = Event.decode(object1),
            let event2 = Event.decode(object2) {
                return event1.date.compare(event2.date)
        }
        return .OrderedSame
    })

    let view = YapDB.View(name: Event.collection, grouping: grouping, sorting: sorting, collections: [Event.collection])

    return .View(view)
}

func events(byColor: Bool = false, mappingBlock: YapDB.FetchConfiguration.MappingsConfigurationBlock? = .None) -> YapDB.FetchConfiguration {
    return YapDB.FetchConfiguration(fetch: events(byColor), block: mappingBlock)
}

func events(byColor: Bool = false, mappingBlock: YapDB.FetchConfiguration.MappingsConfigurationBlock? = .None) -> Configuration<Event> {
    return Configuration(fetch: events(byColor), itemMapper: Event.decode)
}

func eventsWithColor(color: Event.Color, byColor: Bool = false) -> YapDB.Fetch {

    let filtering: YapDB.Filter.Filtering = .ByObject({ (_, group, collection, key, object) -> Bool in
        if let event = Event.decode(object) {
            return event.color == color
        }
        return false
    })

    let filter = YapDB.Filter(name: "\(color) Events", parent: events(byColor), filtering: filtering, collections: [Event.collection])

    return .Filter(filter)
}

func eventsWithColor(color: Event.Color, byColor: Bool = false, mappingBlock: YapDB.FetchConfiguration.MappingsConfigurationBlock? = .None) -> YapDB.FetchConfiguration {
    return YapDB.FetchConfiguration(fetch: eventsWithColor(color, byColor: byColor), block: mappingBlock)
}

func eventsWithColor(color: Event.Color, byColor: Bool = false, mappingBlock: YapDB.FetchConfiguration.MappingsConfigurationBlock? = .None) -> Configuration<Event> {
    return Configuration(fetch: eventsWithColor(color, byColor: byColor), itemMapper: Event.decode)
}








