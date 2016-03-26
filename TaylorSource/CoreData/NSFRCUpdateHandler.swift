import UIKit
import CoreData

private class WeakObserver {
    private(set) weak var value: NSFRCIndexedUpdateConsumer?

    init(_ observer: NSFRCIndexedUpdateConsumer) {
        value = observer
    }
}

public class NSFRCUpdateHandler: NSObject, NSFetchedResultsControllerDelegate {
    
    private var observers = [WeakObserver]()
    private var insertedSections: NSMutableIndexSet!
    private var deletedSections: NSMutableIndexSet!
    private var insertedRows: [NSIndexPath]!
    private var updatedRows: [NSIndexPath]!
    private var deletedRows: [NSIndexPath]!
    
    deinit {
        observers.removeAll()
    }
    
    public func addUpdateObserver(observer: NSFRCIndexedUpdateConsumer) {
        observers.append(WeakObserver(observer))
    }
    
    private func sendUpdate(update: NSFRCIndexedUpdate) {
        observers = observers.filter { $0.value != nil } // Remove orphaned observers
        observers.forEach { $0.value?.handleIndexedUpdate(update) }
    }
    
    private func createUpdateFromCollectedValues() -> NSFRCIndexedUpdate {
        let insertedSections = self.insertedSections.copy() as! NSIndexSet
        let deletedSections = self.deletedSections.copy() as! NSIndexSet
        let update: NSFRCIndexedUpdate = .DeltaUpdate(
            insertedSections: insertedSections,
            deletedSections: deletedSections,
            insertedRows: insertedRows,
            updatedRows: updatedRows,
            deletedRows: deletedRows
        )
        return update
    }
    
    private func clearCollectedValues() {
        insertedSections = nil
        deletedSections = nil
        insertedRows = nil
        updatedRows = nil
        deletedRows = nil
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    

    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedSections = NSMutableIndexSet()
        deletedSections = NSMutableIndexSet()
        insertedRows = []
        updatedRows = []
        deletedRows = []
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch (type) {
        case NSFetchedResultsChangeType.Delete:
            deletedSections.addIndex(Int(sectionIndex))
        case NSFetchedResultsChangeType.Insert:
            insertedSections.addIndex(Int(sectionIndex))
        default:
            break
        }
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case NSFetchedResultsChangeType.Insert:
            if indexPath == nil { // iOS 9 / Swift 2.0 BUG with running 8.4 (https://forums.developer.apple.com/thread/12184)
                if let newIndexPath = newIndexPath {
                    insertedRows.append(newIndexPath)
                }
            }
        case NSFetchedResultsChangeType.Delete:
            if let indexPath = indexPath {
                deletedRows.append(indexPath)
            }
        case NSFetchedResultsChangeType.Update:
            if let indexPath = indexPath {
                updatedRows.append(indexPath)
            }
        case NSFetchedResultsChangeType.Move:
            if
                let newIndexPath = newIndexPath,
                let indexPath = indexPath
            {
                insertedRows.append(newIndexPath)
                deletedRows.append(indexPath)
            }
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        let update = createUpdateFromCollectedValues()
        sendUpdate(update)
        clearCollectedValues()
    }
}
