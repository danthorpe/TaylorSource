//
//  DataSourceEditor.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 28/03/2016.
//
//

import Foundation

/// Namespace for Edit related types
public struct Edit {

    /**
     Enum which describes edit actions for a data source. It uses
     UITableViewCellEditingStyle as it's rawValue.
     */
    public enum Action: RawRepresentable {
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

    public struct Capability: OptionSetType {
        public static let None = Capability(rawValue: 0)
        public static let InsertDelete = Capability(rawValue: 1)
        public static let Reorder = Capability(rawValue: 2)

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    /// Block type which returns a bool indicating whether the item at the index path is editable
    public typealias CanEditItemAtIndexPath = (indexPath: NSIndexPath) -> Bool

    /// Block type which commits the edit action for the item at the index path
    public typealias CommitEditActionForItemAtIndexPath = (action: Action, indexPath: NSIndexPath) -> Void

    /// Block type which returns the edit action for the item at index path
    public typealias EditActionForItemAtIndexPath = (indexPath: NSIndexPath) -> Action

    /// Block type which returns a bool indicating whether the item at index path can be moved
    public typealias CanMoveItemAtIndexPath = (indexPath: NSIndexPath) -> Bool

    /// Block type which commits the move of an item from one index path to another.
    public typealias MoveItemAtIndexPathToIndexPath = (from: NSIndexPath, to: NSIndexPath) -> Void
}

/// An interface for a DataSource Editor
public protocol DataSourceEditorType: class {

    /// - returns: an optional CanEditItemAtIndexPath block
    var canEditItemAtIndexPath: Edit.CanEditItemAtIndexPath? { get }

    /// - returns: an optional CommitEditActionForItemAtIndexPath block
    var commitEditActionForItemAtIndexPath: Edit.CommitEditActionForItemAtIndexPath? { get }

    /// - returns: an optional EditActionForItemAtIndexPath block
    var editActionForItemAtIndexPath: Edit.EditActionForItemAtIndexPath? { get }

    /// - returns: an optional CanMoveItemAtIndexPath block
    var canMoveItemAtIndexPath: Edit.CanMoveItemAtIndexPath? { get }

    /// - returns: an optional CommitMoveItemAtIndexPathToIndexPath block
    var moveItemAtIndexPathToIndexPath: Edit.MoveItemAtIndexPathToIndexPath? { get }
}

extension DataSourceEditorType {

    var supportsEdit: Bool {
        return canEditItemAtIndexPath != nil && commitEditActionForItemAtIndexPath != nil
    }

    var supportsReorder: Bool {
        return canMoveItemAtIndexPath != nil && moveItemAtIndexPathToIndexPath != nil
    }

    public var capability: Edit.Capability {
        switch (supportsEdit, supportsReorder) {
        case (true, false):
            return Edit.Capability.InsertDelete
        case (false, true):
            return Edit.Capability.Reorder
        case (true, true):
            return [Edit.Capability.InsertDelete, Edit.Capability.Reorder]
        default:
            return Edit.Capability.None
        }
    }
}

/**
 Creates a NoEditor which can be used to make types conform to DataSourceProvider
 when the underlying data source does not support editing.
*/
public class NoEditor: DataSourceEditorType {

    /// - returns: .None
    public let canEditItemAtIndexPath: Edit.CanEditItemAtIndexPath? = .None

    /// returns: .None
    public let commitEditActionForItemAtIndexPath: Edit.CommitEditActionForItemAtIndexPath? = .None

    /// returns: .None
    public let editActionForItemAtIndexPath: Edit.EditActionForItemAtIndexPath? = .None

    /// returns: .None
    public let canMoveItemAtIndexPath: Edit.CanMoveItemAtIndexPath? = .None

    /// returns: .None
    public let moveItemAtIndexPathToIndexPath: Edit.MoveItemAtIndexPathToIndexPath? = .None

    /// - returns: a NoEditor value
    public init() { }
}

/**
 Creates a Editor which can be used to make types conform to DataSourceProvider
 when the underlying data source supports editing.
 */
public class Editor: DataSourceEditorType {

    /// - returns: an optional CanEditItemAtIndexPath block
    public let canEditItemAtIndexPath: Edit.CanEditItemAtIndexPath?

    /// returns: an optional CommitEditActionForItemAtIndexPath block
    public let commitEditActionForItemAtIndexPath: Edit.CommitEditActionForItemAtIndexPath?

    /// returns: an optional CommitEditActionForItemAtIndexPath block
    public let editActionForItemAtIndexPath: Edit.EditActionForItemAtIndexPath?

    /// returns: an optional CanMoveItemAtIndexPath block
    public let canMoveItemAtIndexPath: Edit.CanMoveItemAtIndexPath?

    /// returns: an optional CommitMoveItemAtIndexPathToIndexPath block
    public let moveItemAtIndexPathToIndexPath: Edit.MoveItemAtIndexPathToIndexPath?

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
        canEdit: Edit.CanEditItemAtIndexPath? = .None,
        commitEdit: Edit.CommitEditActionForItemAtIndexPath? = .None,
        editAction: Edit.EditActionForItemAtIndexPath? = .None,
        canMove: Edit.CanMoveItemAtIndexPath? = .None,
        move: Edit.MoveItemAtIndexPathToIndexPath? = .None) {
        canEditItemAtIndexPath = canEdit
        commitEditActionForItemAtIndexPath = commitEdit
        editActionForItemAtIndexPath = editAction
        canMoveItemAtIndexPath = canMove
        moveItemAtIndexPathToIndexPath = move
    }
}


