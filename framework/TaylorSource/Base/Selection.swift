//
//  Selection.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 17/08/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import Foundation

public class SelectionManager<Item: Hashable> {

    var selectedItems = Set<Item>()

    public var allowsMultipleSelection: Bool = false
    public var enabled = false

    public var items: [Item] {
        return Array(selectedItems)
    }

    public init(initialSelection: Set<Item> = Set()) {
        selectedItems.unionInPlace(initialSelection)
    }

    public func addItem(item: Item) {
        selectedItems.insert(item)
    }

    public func removeItem(item: Item) {
        selectedItems.remove(item)
    }

    public func contains(item: Item) -> Bool {
        return selectedItems.contains(item)
    }

    public func selectItem(item: Item, shouldRefreshItems: ((itemsToRefresh: [Item]) -> Void)? = .None) {
        enabled = true
        var itemsToUpdate = Set(arrayLiteral: item)
        if contains(item) {
            removeItem(item)
        }
        else {
            if !allowsMultipleSelection {
                itemsToUpdate.unionInPlace(selectedItems)
                selectedItems.removeAll(keepCapacity: false)
            }
            addItem(item)
        }
        shouldRefreshItems?(itemsToRefresh: Array(itemsToUpdate))
    }
}

typealias IndexPathSelectionManager = SelectionManager<NSIndexPath>

