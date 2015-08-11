//
//  EntityDatasourceTests.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 29/07/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//


import UIKit
import XCTest
import TaylorSource

enum TestEntity: String, EntityType {

    case Foo = "Foo"
    case Bar = "Bar"
    case Baz = "Baz"
    case Bat = "Bat"

    var numberOfSections: Int {
        switch self {
        case .Foo: return 2
        case .Bar: return 2
        case .Baz: return 3
        case .Bat: return 4
        }
    }

    func numberOfItemsInSection(sectionIndex: Int) -> Int {
        switch (self, sectionIndex) {
        case (.Foo, _): return 2
        case (.Bar, 0): return 2
        case (.Bar, _): return 3
        case (.Baz, 0): return 1
        case (.Baz, 1): return 3
        case (.Baz, _): return 2
        case (.Bat, 0): return 3
        case (.Bat, 1): return 2
        case (.Bat, _): return 1
        }
    }

    func itemAtIndexPath(indexPath: NSIndexPath) -> String? {
        return "\(rawValue): \(indexPath)"
    }
}

class EntityDatasourceTests: XCTestCase {

    typealias Factory = BasicFactory<String, UITableViewCell, UITableViewHeaderFooterView, StubbedTableView>
    typealias Datasource = EntityDatasource<Factory, TestEntity>

    let view = StubbedTableView()
    let factory = Factory()
    let entity = TestEntity.Bat
    var datasource: Datasource!

    override func setUp() {
        factory.registerCell(.ClassWithIdentifier(UITableViewCell.self, "cell"), inView: view) { (_, _, _) in }
        datasource = Datasource(id: "test entity datasource", factory: factory, entity: entity)
    }

    func test__number_of_sections_in_datasource() {
        // Note - properties does not include .Baz
        XCTAssertEqual(datasource.numberOfSections, 4)
    }

    func test__number_of_items_in_sections() {

        // Bat
        XCTAssertEqual(datasource.numberOfItemsInSection(0), 3)
        XCTAssertEqual(datasource.numberOfItemsInSection(1), 2)
        XCTAssertEqual(datasource.numberOfItemsInSection(2), 1)
        XCTAssertEqual(datasource.numberOfItemsInSection(3), 1)
    }

    func test__item_at_index_path() {
        for section in 0..<datasource.numberOfSections {
            for item in 0..<datasource.numberOfItemsInSection(section) {
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                let item = datasource.itemAtIndexPath(indexPath)
                XCTAssertNotNil(item!)
            }
        }
    }
}

