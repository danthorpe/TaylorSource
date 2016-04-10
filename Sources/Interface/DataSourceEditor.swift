//
//  DataSourceEditor.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 28/03/2016.
//
//

import Foundation

/**
 Enum which describes edit actions for a data source. It uses
 UITableViewCellEditingStyle as it's rawValue.
*/
public enum DataSourceEditAction: RawRepresentable {
    case None, Insert, Delete

    /// - returns: the rawValue is a UITableViewCellEditingStyle
    public var rawValue: UITableViewCellEditingStyle {
        switch self {
        case .None: return .None
        case .Insert: return .Insert
        case .Delete: return .Delete
        }
    }

    /// init with a rawValue of UITableViewCellEditingStyle
    public init?(rawValue: UITableViewCellEditingStyle) {
        switch rawValue {
        case .None:
            self = .None
        case .Insert:
            self = .Insert
        case .Delete:
            self = .Delete
        }
    }
}

/// Block type which returns a bool indicating whether the item at the index path is editable
public typealias CanEditItemAtIndexPath = (indexPath: NSIndexPath) -> Bool

/// Block type which commits the edit action for the item at the index path
public typealias CommitEditActionForItemAtIndexPath = (action: DataSourceEditAction, indexPath: NSIndexPath) -> Void

/// Block type which returns the edit action for the item at index path
public typealias EditActionForItemAtIndexPath = (indexPath: NSIndexPath) -> DataSourceEditAction

/// Block type which returns a bool indicating whether the item at index path can be moved
public typealias CanMoveItemAtIndexPath = (indexPath: NSIndexPath) -> Bool

/// Block type which commits the move of an item from one index path to another.
public typealias CommitMoveItemAtIndexPathToIndexPath = (from: NSIndexPath, to: NSIndexPath) -> Void

/// An interface for a DataSource Editor
public protocol DataSourceEditor {

    /// - returns: an optional CanEditItemAtIndexPath block
    var canEditItemAtIndexPath: CanEditItemAtIndexPath? { get }

    /// - returns: an optional CommitEditActionForItemAtIndexPath block
    var commitEditActionForItemAtIndexPath: CommitEditActionForItemAtIndexPath? { get }

    /// - returns: an optional EditActionForItemAtIndexPath block
    var editActionForItemAtIndexPath: EditActionForItemAtIndexPath? { get }

    /// - returns: an optional CanMoveItemAtIndexPath block
    var canMoveItemAtIndexPath: CanMoveItemAtIndexPath? { get }

    /// - returns: an optional CommitMoveItemAtIndexPathToIndexPath block
    var commitMoveItemAtIndexPathToIndexPath: CommitMoveItemAtIndexPathToIndexPath? { get }
}

public extension DataSourceEditor {

    /// - returns: a Bool to indicate whether editing is fully supported
    var supportsEditing: Bool {
        return canEditItemAtIndexPath != nil &&
            commitEditActionForItemAtIndexPath != nil &&
            canMoveItemAtIndexPath != nil &&
            commitMoveItemAtIndexPathToIndexPath != nil
    }
}

/**
 Creates a NoEditor which can be used to make types conform to DataSourceProvider
 when the underlying data source does not support editing.
*/
public struct NoEditor: DataSourceEditor {

    /// - returns: .None
    public let canEditItemAtIndexPath: CanEditItemAtIndexPath? = .None

    /// returns: .None
    public let commitEditActionForItemAtIndexPath: CommitEditActionForItemAtIndexPath? = .None

    /// returns: .None
    public let editActionForItemAtIndexPath: EditActionForItemAtIndexPath? = .None

    /// returns: .None
    public let canMoveItemAtIndexPath: CanMoveItemAtIndexPath? = .None

    /// returns: .None
    public let commitMoveItemAtIndexPathToIndexPath: CommitMoveItemAtIndexPathToIndexPath? = .None

    /// - returns: a NoEditor value
    public init() { }
}

/**
 Creates a Editor which can be used to make types conform to DataSourceProvider
 when the underlying data source supports editing.
 */
public struct Editor: DataSourceEditor {

    /// - returns: an optional CanEditItemAtIndexPath block
    public let canEditItemAtIndexPath: CanEditItemAtIndexPath?

    /// returns: an optional CommitEditActionForItemAtIndexPath block
    public let commitEditActionForItemAtIndexPath: CommitEditActionForItemAtIndexPath?

    /// returns: an optional CommitEditActionForItemAtIndexPath block
    public let editActionForItemAtIndexPath: EditActionForItemAtIndexPath?

    /// returns: an optional CanMoveItemAtIndexPath block
    public let canMoveItemAtIndexPath: CanMoveItemAtIndexPath?

    /// returns: an optional CommitMoveItemAtIndexPathToIndexPath block
    public let commitMoveItemAtIndexPathToIndexPath: CommitMoveItemAtIndexPathToIndexPath?

    /**
     Creates an Editor value.
     - parameter canEdit: an optional CanEditItemAtIndexPath block, defaults to .None
     - parameter commitEdit: an optional CommitEditActionForItemAtIndexPath block, defaults to .None
     - parameter editAction: an optional CommitEditActionForItemAtIndexPath block, defaults to .None
     - parameter canMove: an optional CanMoveItemAtIndexPath block, defaults to .None
     - parameter commitMove: an optional CommitMoveItemAtIndexPathToIndexPath block, defaults to .None
     - returns: an Editor value with the provided blocks
    */
    public init(
        canEdit: CanEditItemAtIndexPath? = .None,
        commitEdit: CommitEditActionForItemAtIndexPath? = .None,
        editAction: EditActionForItemAtIndexPath? = .None,
        canMove: CanMoveItemAtIndexPath? = .None,
        commitMove: CommitMoveItemAtIndexPathToIndexPath? = .None) {
        canEditItemAtIndexPath = canEdit
        commitEditActionForItemAtIndexPath = commitEdit
        editActionForItemAtIndexPath = editAction
        canMoveItemAtIndexPath = canMove
        commitMoveItemAtIndexPathToIndexPath = commitMove
    }
}


