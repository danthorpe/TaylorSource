//
//  Created by Daniel Thorpe on 16/04/2015.
//

import YapDatabase

public protocol UpdatableView {
    typealias ProcessChangesType
    var processChanges: ProcessChangesType { get }
}

public struct YapDBCellIndex: IndexPathIndexType {
    public let indexPath: NSIndexPath
    public let transaction: YapDatabaseReadTransaction
}

public struct YapDBSupplementaryIndex: IndexPathIndexType {
    public let group: String
    public let indexPath: NSIndexPath
    public let transaction: YapDatabaseReadTransaction
}

public class YapDBFactory<
    Item, Cell, SupplementaryView, View
    where
    View: CellBasedView>: Factory<Item, Cell, SupplementaryView, View, YapDBCellIndex, YapDBSupplementaryIndex> {

    public override init(cell: GetCellKey, supplementary: GetSupplementaryKey) {
        super.init(cell: cell, supplementary: supplementary)
    }

    public convenience init(cellKey: String, supplementaryKey: String) {
        self.init(
            cell: { (_, _) in cellKey },
            supplementary: { _ in supplementaryKey }
        )
    }
}

// MARK: - UpdatableView

extension UITableView: UpdatableView {

    public var processChanges: YapDatabaseViewMappings.Changes {
        return { [weak self] changeset in
            if let weakSelf = self {
                weakSelf.tay_performBatchUpdates {
                    weakSelf.processSectionChanges(changeset.sections)
                    weakSelf.processRowChanges(changeset.items)
                }
            }
        }
    }

    func processSectionChanges(sectionChanges: [YapDatabaseViewSectionChange]) {
        for change in sectionChanges {
            let indexes = NSIndexSet(index: Int(change.index))
            switch change.type {
            case .Delete:
                deleteSections(indexes, withRowAnimation: .Automatic)
            case .Insert:
                insertSections(indexes, withRowAnimation: .Automatic)
            default:
                break
            }
        }
    }

    func processRowChanges(rowChanges: [YapDatabaseViewRowChange]) {
        for change in rowChanges {
            switch change.type {
            case .Delete:
                deleteRowsAtIndexPaths([change.indexPath], withRowAnimation: .Automatic)
            case .Insert:
                insertRowsAtIndexPaths([change.newIndexPath], withRowAnimation: .Automatic)
            case .Move:
                deleteRowsAtIndexPaths([change.indexPath], withRowAnimation: .Automatic)
                insertRowsAtIndexPaths([change.newIndexPath], withRowAnimation: .Automatic)
            case .Update:
                reloadRowsAtIndexPaths([change.indexPath], withRowAnimation: .Automatic)
            }
        }
    }
}

extension UICollectionView: UpdatableView {

    public var processChanges: YapDatabaseViewMappings.Changes {
        return { [weak self] changeset in
            if let weakSelf = self {
                weakSelf.tay_performBatchUpdates({
                    weakSelf.processSectionChanges(changeset.sections)
                    weakSelf.processItemChanges(changeset.items)
                }, completion: .None)
            }
        }
    }

    func processSectionChanges(sectionChanges: [YapDatabaseViewSectionChange]) {
        for change in sectionChanges {
            let indexes = NSIndexSet(index: Int(change.index))
            switch change.type {
            case .Delete:
                deleteSections(indexes)
            case .Insert:
                insertSections(indexes)
            default:
                break
            }
        }
    }

    func processItemChanges(itemChanges: [YapDatabaseViewRowChange]) {
        for change in itemChanges {
            switch change.type {
            case .Delete:
                deleteItemsAtIndexPaths([change.indexPath])
            case .Insert:
                insertItemsAtIndexPaths([change.newIndexPath])
            case .Move:
                deleteItemsAtIndexPaths([change.indexPath])
                insertItemsAtIndexPaths([change.newIndexPath])
            case .Update:
                reloadItemsAtIndexPaths([change.indexPath])
            }
        }
    }
}

