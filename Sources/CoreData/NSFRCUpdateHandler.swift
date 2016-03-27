import UIKit
import CoreData

extension NSIndexSet {
    class func indexSetFromSet(set: Set<Int>) -> NSIndexSet {
        var indexSet = NSMutableIndexSet()
        set.forEach { indexSet.addIndex($0) }
        return indexSet.copy() as! NSIndexSet
    }
}

public class NSFRCUpdateHandler: NSObject, NSFetchedResultsControllerDelegate {
    
    private class WeakObserver {
        private(set) weak var value: NSFRCIndexedUpdateConsumer?
        
        init(_ observer: NSFRCIndexedUpdateConsumer) {
            value = observer
        }
    }
    
    private struct PendingUpdates {
        var insertedSections = Set<Int>()
        var deletedSections = Set<Int>()
        var insertedRows = Set<NSIndexPath>()
        var updatedRows = Set<NSIndexPath>()
        var deletedRows = Set<NSIndexPath>()
        
        func createUpdate() -> NSFRCIndexedUpdate {
            let update: NSFRCIndexedUpdate = .DeltaUpdate(
                insertedSections: NSIndexSet.indexSetFromSet(insertedSections),
                deletedSections: NSIndexSet.indexSetFromSet(deletedSections),
                insertedRows: Array(insertedRows),
                updatedRows: Array(updatedRows),
                deletedRows: Array(deletedRows)
            )
            return update
        }
    }

    private var observers = [WeakObserver]()
    private var pendingUpdates = PendingUpdates()
    
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
    
    // MARK: NSFetchedResultsControllerDelegate
    
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch (type) {
        case NSFetchedResultsChangeType.Delete:
            pendingUpdates.deletedSections.insert(sectionIndex)
        case NSFetchedResultsChangeType.Insert:
            pendingUpdates.insertedSections.insert(sectionIndex)
        default:
            break
        }
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case NSFetchedResultsChangeType.Insert:
            if indexPath == nil { // iOS 9 / Swift 2.0 BUG with running 8.4 (https://forums.developer.apple.com/thread/12184)
                if let newIndexPath = newIndexPath {
                    pendingUpdates.insertedRows.insert(newIndexPath)
                }
            }
        case NSFetchedResultsChangeType.Delete:
            if let indexPath = indexPath {
                pendingUpdates.deletedRows.insert(indexPath)
            }
        case NSFetchedResultsChangeType.Update:
            if let indexPath = indexPath {
                pendingUpdates.updatedRows.insert(indexPath)
            }
        case NSFetchedResultsChangeType.Move:
            if
                let newIndexPath = newIndexPath,
                let indexPath = indexPath
            {
                pendingUpdates.insertedRows.insert(newIndexPath)
                pendingUpdates.deletedRows.insert(indexPath)
            }
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        let update = pendingUpdates.createUpdate()
        sendUpdate(update)
        pendingUpdates = PendingUpdates()
    }
}
