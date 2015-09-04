//
//  Created by Daniel Thorpe on 16/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import YapDatabase
import YapDatabaseExtensions
import TaylorSource

// MARK: - Domain

public struct Event {

    public enum Color {
        case Red, Blue, Green
    }

    let uuid: String
    let color: Color
    let date: NSDate

    public init(uuid u: String, color c: Color, date d: NSDate) {
        uuid = u
        date = d
        color = c
    }

    public static func create(color color: Color = .Red) -> Event {
        return Event(uuid: NSUUID().UUIDString, color: color, date: NSDate())
    }
}

// MARK: - Model Helpers

extension Event.Color: CustomStringConvertible {

    public var description: String {
        switch self {
        case .Red: return "Red"
        case .Blue: return "Blue"
        case .Green: return "Green"
        }
    }
}

extension Event.Color: Equatable { }

public func == (a: Event.Color, b: Event.Color) -> Bool {
    switch (a,b) {
    case (.Red, .Red), (.Blue, .Blue), (.Green, .Green): return true
    default: return false
    }
}

extension Event: Equatable { }

public func == (a: Event, b: Event) -> Bool {
    return (a.color == b.color) && (a.uuid == b.uuid) && (a.date == b.date)
}

extension Event.Color: Saveable {
    public typealias Archive = EventColorArchiver

    enum Kind: Int {
        case Red = 1, Blue, Green
    }

    public var archive: Archive {
        return Archive(self)
    }

    var kind: Kind {
        switch self {
        case .Red: return Kind.Red
        case .Blue: return Kind.Blue
        case .Green: return Kind.Green
        }
    }
}

public class EventColorArchiver: NSObject, NSCoding, Archiver {

    public let value: Event.Color

    public required init(_ v: Event.Color) {
        value = v
    }

    public required init?(coder aDecoder: NSCoder) {
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

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(value.kind.rawValue, forKey: "kind")
    }
}

extension Event: Identifiable {
    public var identifier: String {
        return uuid
    }
}

extension Event: Persistable {
    public static var collection: String {
        return "Events"
    }
}

extension Event: Saveable {
    public typealias Archive = EventArchiver

    public var archive: Archive {
        return Archive(self)
    }
}

public class EventArchiver: NSObject, NSCoding, Archiver {

    public let value: Event

    public required init(_ v: Event) {
        value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        let color = Event.Color(aDecoder.decodeObjectForKey("color"))
        let uuid = aDecoder.decodeObjectForKey("uuid") as? String
        let date = aDecoder.decodeObjectForKey("date") as? NSDate
        value = Event(uuid: uuid!, color: color!, date: date!)
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.color.archive, forKey: "color")
        aCoder.encodeObject(value.uuid, forKey: "uuid")
        aCoder.encodeObject(value.date, forKey: "date")
    }
}

// MARK: - Database Fetch Configurations

public func events(byColor: Bool = false) -> YapDB.Fetch {

    let grouping: YapDB.View.Grouping = .ByObject({ (_, collection, key, object) -> String! in
        if collection == Event.collection {
            if !byColor {
                return collection
            }

            if let event = Event.unarchive(object) {
                return event.color.description
            }
        }
        return .None
    })

    let sorting: YapDB.View.Sorting = .ByObject({ (_, group, collection1, key1, object1, collection2, key2, object2) -> NSComparisonResult in
        if  let event1 = Event.unarchive(object1),
            let event2 = Event.unarchive(object2) {
                return event1.date.compare(event2.date)
        }
        return .OrderedSame
    })

    let view = YapDB.View(name: Event.collection, grouping: grouping, sorting: sorting, collections: [Event.collection])

    return .View(view)
}

public func events(byColor: Bool = false, mappingBlock: YapDB.FetchConfiguration.MappingsConfigurationBlock? = .None) -> YapDB.FetchConfiguration {
    return YapDB.FetchConfiguration(fetch: events(byColor), block: mappingBlock)
}

public func events(byColor: Bool = false, mappingBlock: YapDB.FetchConfiguration.MappingsConfigurationBlock? = .None) -> Configuration<Event> {
    return Configuration(fetch: events(byColor), itemMapper: Event.unarchive)
}

public func eventsWithColor(color: Event.Color, byColor: Bool = false) -> YapDB.Fetch {

    let filtering: YapDB.Filter.Filtering = .ByObject({ (_, group, collection, key, object) -> Bool in
        if let event = Event.unarchive(object) {
            return event.color == color
        }
        return false
    })

    let filter = YapDB.Filter(name: "\(color) Events", parent: events(byColor), filtering: filtering, collections: [Event.collection])

    return .Filter(filter)
}

public func eventsWithColor(color: Event.Color, byColor: Bool = false, mappingBlock: YapDB.FetchConfiguration.MappingsConfigurationBlock? = .None) -> YapDB.FetchConfiguration {
    return YapDB.FetchConfiguration(fetch: eventsWithColor(color, byColor: byColor), block: mappingBlock)
}

public func eventsWithColor(color: Event.Color, byColor: Bool = false, mappingBlock: YapDB.FetchConfiguration.MappingsConfigurationBlock? = .None) -> Configuration<Event> {
    return Configuration(fetch: eventsWithColor(color, byColor: byColor), itemMapper: Event.unarchive)
}



