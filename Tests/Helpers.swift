//
//  Created by Daniel Thorpe on 19/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit

import YapDatabase
import ValueCoding
import YapDatabaseExtensions
import TaylorSource

class StubbedTableView: UITableView {
    override func dequeueCellWithIdentifier(id: String, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell(style: .Default, reuseIdentifier: id)
    }

    override func dequeueReusableHeaderFooterViewWithIdentifier(identifier: String) -> UITableViewHeaderFooterView? {
        return UITableViewHeaderFooterView(reuseIdentifier: identifier)
    }
}

class StubbedCollectionView: UICollectionView {
    override func dequeueCellWithIdentifier(id: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return UICollectionViewCell()
    }

    override func dequeueReusableSupplementaryViewOfKind(elementKind: String, withReuseIdentifier identifier: String, forIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
}

extension NSIndexPath {
    static var first: NSIndexPath {
        return NSIndexPath(forItem: 0, inSection: 0)
    }
}

// MARK: - Fake Models

struct Person {
    enum Gender: Int {
        case Unknown = 1, Female, Male
    }

    let age: Int
    let gender: Gender
    let name: String
}

class PersonCoder: NSObject, NSCoding, CodingType {
    let value: Person

    required init(_ v: Person) {
        value = v
    }

    required init?(coder aDecoder: NSCoder) {
        if let gender = Person.Gender(rawValue: aDecoder.decodeIntegerForKey("gender")) {
            let age = aDecoder.decodeIntegerForKey("age")
            let name = aDecoder.decodeObjectForKey("name") as! String
            value = Person(age: age, gender: gender, name: name)
        }
        else { fatalError("Person.Gender not encoded correctly") }
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(value.age, forKey: "age")
        aCoder.encodeInteger(value.gender.rawValue, forKey: "gender")
        aCoder.encodeObject(value.name, forKey: "name")
    }
}

extension Person: ValueCoding {
    typealias Coder = PersonCoder
}

extension Person.Gender: CustomStringConvertible {
    var description: String {
        switch self {
        case .Unknown: return "Unknown"
        case .Female: return "Female"
        case .Male: return "Male"
        }
    }
}

extension Person: Identifiable {

    var identifier: Identifier {
        return "\(name) - \(gender) - \(age)"
    }
}

extension Person: Persistable {

    static var collection: String {
        return "People"
    }
}

extension Person: CustomStringConvertible {
    var description: String {
        return "\(name), \(gender) \(age)"
    }
}

func generateRandomPeople(count: Int) -> [Person] {

    let possibleNames: [(Person.Gender, String)] = [
        (.Male, "Tony"),
        (.Male, "Thor"),
        (.Male, "Bruce"),
        (.Male, "Steve"),
        (.Female, "Natasha"),
        (.Male, "Clint"),
        (.Unknown, "Ultron"),
        (.Male, "Nick"),
        (.Male, "James"),
        (.Male, "Pietro"),
        (.Female, "Wanda"),
        (.Unknown, "Jarvis"),
        (.Female, "Maria"),
        (.Male, "Sam"),
        (.Female, "Peggy")
    ]

    func createRandomPerson(_: Int) -> Person {
        let index = Int(arc4random_uniform(UInt32(possibleNames.endIndex)))
        let rando = possibleNames[index]
        let age = 25 + Int(arc4random_uniform(20))
        return Person(age: age, gender: rando.0, name: rando.1)
    }

    return Array(0..<count).map(createRandomPerson)
}

func people(name: String, byGroup createGroup: (Person) -> String) -> YapDB.Fetch {

    let grouping: YapDB.View.Grouping = .ByObject({ (_, collection, key, object) -> String! in
        if collection == Person.collection {
            if let person = Person.decode(object) {
                return createGroup(person)
            }
        }
        return .None
    })

    let sorting: YapDB.View.Sorting = .ByObject({ (_, group, collection1, key1, object1, collection2, key2, object2) -> NSComparisonResult in
        if  let person1 = Person.decode(object1),
            let person2 = Person.decode(object2) {
                let comparison = person1.name.caseInsensitiveCompare(person2.name)
                switch comparison {
                case .OrderedSame:
                    return person1.age < person2.age ? .OrderedAscending : .OrderedDescending
                default:
                    return comparison
                }
        }
        return .OrderedSame
    })

    let view = YapDB.View(name: name, grouping: grouping, sorting: sorting, collections: [Person.collection])
    return .View(view)
}

func people(name: String, byGroup createGroup: (Person) -> String) -> YapDB.FetchConfiguration {
    return YapDB.FetchConfiguration(fetch: people(name, byGroup: createGroup))
}

func people(name: String, byGroup createGroup: (Person) -> String) -> Configuration<Person> {
    return Configuration(fetch: people(name, byGroup: createGroup), itemMapper: Person.decode)
}





