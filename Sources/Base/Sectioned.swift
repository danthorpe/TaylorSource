import Foundation

/**
 Objects adopting this protocol can be used as sections in a sectioned data source.

 A section can be anything, as long as it supplies an array of items in that section.

 Adding additional properties, such as the section title or an icon, will allow
 you to properly customize supplementary views, such as section headers or footers.
 */
public protocol SectionType: SequenceType, CollectionType {
    associatedtype ItemType
    var items: [ItemType] { get }
}

// Let SectionType behave as a sequence of ItemType elements
extension SectionType where Self: SequenceType {
    public func generate() -> Array<ItemType>.Generator {
        return items.generate()
    }
}

// Let SectionType behave as a collection of ItemType elements
extension SectionType where Self: CollectionType {
    public var startIndex: Int {
        return items.startIndex
    }

    public var endIndex: Int {
        return items.endIndex
    }

    public subscript(i: Int) -> ItemType {
        return items[i]
    }
}

/**
 A concrete implementation of `DatasourceType` for a fixed set of sectioned data.

 The data source is initalized with the section models it contains. Each section
 contains an immutable array of the items in that section.

 The cell and supplementary index types are both `NSIndexPath`, making this class
 compatible with a `BasicFactory`. This also means that the configuration block for
 cells and supplementary views will receive an NSIndexPath as their index argument.
 */
public class StaticSectionDatasource<Factory, StaticSectionType where
    Factory: _FactoryType,
    Factory.CellIndexType == NSIndexPath,
    Factory.SupplementaryIndexType == NSIndexPath,
    StaticSectionType: SectionType,
    StaticSectionType.ItemType == Factory.ItemType>: DatasourceType {

    public typealias FactoryType = Factory

    public var title: String?
    public let factory: Factory
    public let identifier: String
    private var sections: [StaticSectionType]

    /**
     The designated initializer.

     - parameter id: A `String` identifier.
     - parameter factory: A `Factory` whose `CellIndexType` and `SupplementaryIndexType` must be `NSIndexPath`, such as `BasicFactory`.
     - parameter sections: An array of `SectionType` instances where `SectionType.ItemType` matches `Factory.ItemType`.
     */
    public init(id: String, factory f: Factory, sections s: [StaticSectionType]) {
        identifier = id
        factory = f
        sections = s
    }

    /// The number of sections.
    public var numberOfSections: Int {
        return sections.count
    }

    /// The number of items in the section with the given index.
    public func numberOfItemsInSection(sectionIndex: Int) -> Int {
        return sections[sectionIndex].items.count
    }

    /**
     Access the section model object for a given index.

     Use this to configure any supplementary views, headers and footers.

     - parameter index: The index of the section.
     - returns: The section object at `index` or `.None` if `index` is out of bounds.
     */
    public func sectionAtIndex(index: Int) -> StaticSectionType? {
        if sections.startIndex <= index && index < sections.endIndex {
            return sections[index]
        }
        return nil
    }

    /**
     The item for a given index path.
 
     - parameter indexPath: The index path of the item.
     - returns: The item at `indexPath` or `.None` if `indexPath` is out of bounds.
     */
    public func itemAtIndexPath(indexPath: NSIndexPath) -> Factory.ItemType? {
        guard let section = sectionAtIndex(indexPath.section) else {
            return .None
        }
        if sections.startIndex <= indexPath.item && indexPath.item < sections.endIndex {
            return section[indexPath.item]
        }
        return nil
    }

    /**
     Returns a configured cell.

     The cell is dequeued from the supplied view and configured with the item at the
     supplied index path.

     Note, that while `itemAtIndexPath` will gracefully return `.None` if the
     index path is out of range, this method will trigger a fatal error if
     `indexPath` does not reference a valid entry in the dataset.

     - parameter view: The containing view instance responsible for dequeueing.
     - parameter indexPath: The `NSIndexPath` for the item.
     - returns: A dequeued and configured instance of `Factory.CellType`.
     */
    public func cellForItemInView(view: Factory.ViewType, atIndexPath indexPath: NSIndexPath) -> Factory.CellType {
        if let item = itemAtIndexPath(indexPath) {
            return factory.cellForItem(item, inView: view, atIndex: indexPath)
        }
        fatalError("No item available at index path: \(indexPath)")
    }

    /**
     Returns a configured supplementary view.

     This is the result of running any registered closure from the factory
     for this supplementary element kind.

     - parameter view: The containing view instance responsible for dequeueing.
     - parameter kind: The `SupplementaryElementKind` of the supplementary view.
     - parameter indexPath: The `NSIndexPath` for the item.
     - returns: A dequeued and configured instance of `Factory.SupplementaryViewType`.
     */
    public func viewForSupplementaryElementInView(view: Factory.ViewType, kind: SupplementaryElementKind, atIndexPath indexPath: NSIndexPath) -> Factory.SupplementaryViewType? {
        return factory.supplementaryViewForKind(kind, inView: view, atIndex: indexPath)
    }

    /**
     Returns an optional text for the supplementary element kind

     - parameter view: The containing view instance responsible for dequeueing.
     - parameter kind: The `SupplementaryElementKind` of the supplementary view.
     - parameter indexPath: The `NSIndexPath` for the item.
     - returns: A `TextType?` for the supplementary element.
     */
    public func textForSupplementaryElementInView(view: Factory.ViewType, kind: SupplementaryElementKind, atIndexPath indexPath: NSIndexPath) -> Factory.TextType? {
        return factory.supplementaryTextForKind(kind, atIndex: indexPath)
    }
}

// Let StaticSectionDatasource behave as a sequence of StaticSectionType elements
extension StaticSectionDatasource: SequenceType {
    public func generate() -> Array<StaticSectionType>.Generator {
        return sections.generate()
    }
}

// Let StaticSectionDatasource behave as a collection of StaticSectionType elements
extension StaticSectionDatasource: CollectionType {
    public var startIndex: Int {
        return sections.startIndex
    }

    public var endIndex: Int {
        return sections.endIndex
    }

    public subscript(i: Int) -> StaticSectionType {
        return sections[i]
    }
}
