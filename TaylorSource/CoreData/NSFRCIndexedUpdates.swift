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
            self.beginUpdates()
            self.insertSections(insertedSections, withRowAnimation: .Automatic)
            self.deleteSections(deletedSections, withRowAnimation: .Automatic)
            self.insertRowsAtIndexPaths(insertedRows, withRowAnimation: .Automatic)
            self.deleteRowsAtIndexPaths(deletedRows, withRowAnimation: .Automatic)
            self.reloadRowsAtIndexPaths(updatedRows, withRowAnimation: .Automatic)
            self.endUpdates()
        case .FullUpdate:
            self.reloadData()
        }
    }
}

extension UICollectionView: NSFRCIndexedUpdateConsumer {
    public func handleIndexedUpdate(update: NSFRCIndexedUpdate) {
        switch update {
        case .DeltaUpdate(let insertedSections, let deletedSections, let insertedRows, let updatedRows, let deletedRows):
            self.performBatchUpdates({
                self.insertSections(insertedSections)
                self.deleteSections(deletedSections)
                self.insertItemsAtIndexPaths(insertedRows)
                self.deleteItemsAtIndexPaths(deletedRows)
                self.reloadItemsAtIndexPaths(updatedRows)
                }, completion: { _ in })
        case .FullUpdate:
            self.reloadData()
        }
    }
}