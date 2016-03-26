import UIKit
import CoreData

public struct NSFRCDatasource<
    Factory
    where
    Factory: _FactoryType,
    Factory.ViewType: NSFRCIndexedUpdateConsumer,
    Factory.CellIndexType == NSFRCCellIndex,
Factory.SupplementaryIndexType == NSFRCSupplementaryIndex>: DatasourceType {
    
    public typealias FactoryType = Factory
    
    public let identifier: String
    public let factory: Factory
    public var title: String? = .None
    public let updateHandler = NSFRCUpdateHandler()
    public var selectionManager = IndexPathSelectionManager()
    
    private let fetchedResultsController: NSFetchedResultsController
    
    public init(id: String, fetchedResultsController: NSFetchedResultsController, factory f: Factory) {
        fetchedResultsController.delegate = updateHandler
        self.fetchedResultsController = fetchedResultsController
        identifier = id
        factory = f
    }
    
    public var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    public func numberOfItemsInSection(sectionIndex: Int) -> Int {
        if let section = fetchedResultsController.sections?[sectionIndex] {
            return section.numberOfObjects
        }
        return 0
    }
    
    public func itemAtIndexPath(indexPath: NSIndexPath) -> Factory.ItemType? {
        if let obj = fetchedResultsController.objectAtIndexPath(indexPath) as? Factory.ItemType {
            return obj
        }
        return nil
    }
    
    public func cellForItemInView(view: Factory.ViewType, atIndexPath indexPath: NSIndexPath) -> Factory.CellType {
        let selected = selectionManager.enabled && selectionManager.contains(indexPath)
        if let item = itemAtIndexPath(indexPath) {
            let index = NSFRCCellIndex(indexPath: indexPath, selected: selected)
            return factory.cellForItem(item, inView: view, atIndex: index)
        }
        fatalError("No item available at index path: \(indexPath)")
    }
    
    public func viewForSupplementaryElementInView(view: Factory.ViewType, kind: SupplementaryElementKind, atIndexPath indexPath: NSIndexPath) -> Factory.SupplementaryViewType? {
        if
            let section = fetchedResultsController.sections?[indexPath.section],
            let title = section.indexTitle
        {
            let index = NSFRCSupplementaryIndex(group: title, indexPath: indexPath)
            return factory.supplementaryViewForKind(kind, inView: view, atIndex: index)
        }
        return nil
    }
    
    public func textForSupplementaryElementInView(view: FactoryType.ViewType, kind: SupplementaryElementKind, atIndexPath indexPath: NSIndexPath) -> FactoryType.TextType? {
        if
            let section = fetchedResultsController.sections?[indexPath.section],
            let title = section.indexTitle
        {
            let index = NSFRCSupplementaryIndex(group: title, indexPath: indexPath)
            return factory.supplementaryTextForKind(kind, atIndex: index)
        }
        return nil
    }
}
