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
        self.observers.removeAll()
    }
    
    public func addUpdateObserver(observer: NSFRCIndexedUpdateConsumer) {
        self.observers.append(WeakObserver(observer))
    }
    
    private func sendUpdate(update: NSFRCIndexedUpdate) {
        self.observers = self.observers.filter { $0.value != nil } // Remove orphaned observers
        self.observers.forEach { $0.value?.handleIndexedUpdate(update) }
    }
    
    private func createUpdateFromCollectedValues() -> NSFRCIndexedUpdate {
        let insertedSections = self.insertedSections.copy() as! NSIndexSet
        let deletedSections = self.deletedSections.copy() as! NSIndexSet
        let update: NSFRCIndexedUpdate = .DeltaUpdate(
            insertedSections: insertedSections,
            deletedSections: deletedSections,
            insertedRows: self.insertedRows,
            updatedRows: self.updatedRows,
            deletedRows: self.deletedRows
        )
        return update
    }
    
    private func clearCollectedValues() {
        self.insertedSections = nil
        self.deletedSections = nil
        self.insertedRows = nil
        self.updatedRows = nil
        self.deletedRows = nil
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    

    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.insertedSections = NSMutableIndexSet()
        self.deletedSections = NSMutableIndexSet()
        self.insertedRows = []
        self.updatedRows = []
        self.deletedRows = []
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch (type) {
        case NSFetchedResultsChangeType.Delete:
            self.deletedSections.addIndex(Int(sectionIndex))
        case NSFetchedResultsChangeType.Insert:
            self.insertedSections.addIndex(Int(sectionIndex))
        default:
            break
        }
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case NSFetchedResultsChangeType.Insert:
            if indexPath == nil { // iOS 9 / Swift 2.0 BUG with running 8.4 (https://forums.developer.apple.com/thread/12184)
                if let newIndexPath = newIndexPath {
                    self.insertedRows.append(newIndexPath)
                }
            }
        case NSFetchedResultsChangeType.Delete:
            if let indexPath = indexPath {
                self.deletedRows.append(indexPath)
            }
        case NSFetchedResultsChangeType.Update:
            if let indexPath = indexPath {
                self.updatedRows.append(indexPath)
            }
        case NSFetchedResultsChangeType.Move:
            if
                let newIndexPath = newIndexPath,
                let indexPath = indexPath
            {
                    self.insertedRows.append(newIndexPath)
                    self.deletedRows.append(indexPath)
            }
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        let update = self.createUpdateFromCollectedValues()
        self.sendUpdate(update)
        self.clearCollectedValues()
    }
}
