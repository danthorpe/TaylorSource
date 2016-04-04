import Foundation

public enum NSFRCIndexedUpdate {
    case DeltaUpdate(
        insertedSections: NSIndexSet,
        deletedSections: NSIndexSet,
        insertedRows: [NSIndexPath],
        updatedRows: [NSIndexPath],
        deletedRows: [NSIndexPath]
    )
    case FullUpdate
}

public protocol NSFRCIndexedUpdateConsumer: AnyObject {
    func handleIndexedUpdate(update: NSFRCIndexedUpdate)
}

extension UITableView: NSFRCIndexedUpdateConsumer {
    public func handleIndexedUpdate(update: NSFRCIndexedUpdate) {
        switch update {
        case .DeltaUpdate(let insertedSections, let deletedSections, let insertedRows, let updatedRows, let deletedRows):
            beginUpdates()
            insertSections(insertedSections, withRowAnimation: .Automatic)
            deleteSections(deletedSections, withRowAnimation: .Automatic)
            insertRowsAtIndexPaths(insertedRows, withRowAnimation: .Automatic)
            deleteRowsAtIndexPaths(deletedRows, withRowAnimation: .Automatic)
            reloadRowsAtIndexPaths(updatedRows, withRowAnimation: .Automatic)
            endUpdates()
        case .FullUpdate:
            reloadData()
        }
    }
}

extension UICollectionView: NSFRCIndexedUpdateConsumer {
    public func handleIndexedUpdate(update: NSFRCIndexedUpdate) {
        switch update {
        case .DeltaUpdate(let insertedSections, let deletedSections, let insertedRows, let updatedRows, let deletedRows):
            performBatchUpdates({
                self.insertSections(insertedSections)
                self.deleteSections(deletedSections)
                self.insertItemsAtIndexPaths(insertedRows)
                self.deleteItemsAtIndexPaths(deletedRows)
                self.reloadItemsAtIndexPaths(updatedRows)
                }, completion: { _ in })
        case .FullUpdate:
            reloadData()
        }
    }
}