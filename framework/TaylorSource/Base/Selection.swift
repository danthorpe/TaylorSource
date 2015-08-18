//
//  Selection.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 17/08/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import Foundation

public class SelectionManager {

    var selectedIndexPaths = Set<NSIndexPath>()

    public var allowsMultipleSelection: Bool = false
    public var enabled = false

    public var indexPaths: [NSIndexPath] {
        return Array(selectedIndexPaths)
    }

    public init() { }

    public func addIndexPath(indexPath: NSIndexPath) {
        selectedIndexPaths.insert(indexPath)
    }

    public func removeIndexPath(indexPath: NSIndexPath) {
        selectedIndexPaths.remove(indexPath)
    }

    public func contains(itemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return selectedIndexPaths.contains(indexPath)
    }

    public func selectItemAtIndexPath(indexPath: NSIndexPath, shouldRefreshItems: ((indexPathsToRefresh: [NSIndexPath]) -> Void)? = .None) {
        enabled = true
        var itemsToUpdate = Set(arrayLiteral: indexPath)
        if contains(itemAtIndexPath: indexPath) {
            removeIndexPath(indexPath)
        }
        else {
            if !allowsMultipleSelection {
                itemsToUpdate.unionInPlace(selectedIndexPaths)
                selectedIndexPaths.removeAll(keepCapacity: false)
            }
            addIndexPath(indexPath)
        }
        shouldRefreshItems?(indexPathsToRefresh: Array(itemsToUpdate))
    }
}



