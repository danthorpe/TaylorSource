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

public typealias IndexedUpdateProcessor = (NSFRCIndexedUpdate -> ())

public protocol IndexedUpdateProcessing {
    var updateProcessor: IndexedUpdateProcessor { get }
}

extension UITableView: IndexedUpdateProcessing {

    public var updateProcessor: IndexedUpdateProcessor {
        return { [weak self] update in
            switch update {
            case .DeltaUpdate(let insertedSections, let deletedSections, let insertedRows, let updatedRows, let deletedRows):
                self?.beginUpdates()
                self?.insertSections(insertedSections, withRowAnimation: .Automatic)
                self?.deleteSections(deletedSections, withRowAnimation: .Automatic)
                self?.insertRowsAtIndexPaths(insertedRows, withRowAnimation: .Automatic)
                self?.deleteRowsAtIndexPaths(deletedRows, withRowAnimation: .Automatic)
                self?.reloadRowsAtIndexPaths(updatedRows, withRowAnimation: .Automatic)
                self?.endUpdates()
            case .FullUpdate:
                self?.reloadData()
            }
        }
    }
}

extension UICollectionView: IndexedUpdateProcessing {

    public var updateProcessor: IndexedUpdateProcessor {
        return { [weak self] update in
            switch update {
            case .DeltaUpdate(let insertedSections, let deletedSections, let insertedRows, let updatedRows, let deletedRows):
                guard let strongSelf = self else { return }
                strongSelf.performBatchUpdates({
                    strongSelf.insertSections(insertedSections)
                    strongSelf.deleteSections(deletedSections)
                    strongSelf.insertItemsAtIndexPaths(insertedRows)
                    strongSelf.deleteItemsAtIndexPaths(deletedRows)
                    strongSelf.reloadItemsAtIndexPaths(updatedRows)
                    }, completion: { _ in })
            case .FullUpdate:
                self?.reloadData()
            }
        }
    }
}