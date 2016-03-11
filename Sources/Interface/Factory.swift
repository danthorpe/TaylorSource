//
//  Created by Daniel Thorpe on 20/04/2015.
//

import Foundation

/**
 An abstract protocol which defines the associated
 types in use by Factories in TaylorSource.
*/
public protocol AbstractFactoryType {

    /// The type of the model item behind each cell
    typealias ItemType

    /// The type of the cell - i.e. custom cell class
    typealias CellType

    /// The type of the supplementary view
    typealias SupplementaryViewType

    /// The type of the containing view, which must be based around cells,
    /// i.e. UITableView, UICollectionView or subclass
    typealias ViewType: CellBasedViewType

    /// The type of the cell index, used to associate additional metadata
    /// with the index
    typealias CellIndexType: IndexPathIndexType

    /// The type of the supplementary (i.e. header) index, used to
    /// associate additional metadata with the index
    typealias SupplementaryIndexType: IndexPathIndexType

    /// The type of any associated text, e.g. String, or NSAttributedString
    typealias TextType

    /// The type of the block used to configure cells
    typealias CellConfigurationBlock = (cell: CellType, item: ItemType, index: CellIndexType) -> Void

    /// The type of the block used to configure supplementary views
    typealias SupplementaryViewConfigurationBlock = (supplementaryView: SupplementaryViewType, index: SupplementaryIndexType) -> Void

    /// The type of the block used to configure/get supplementary text
    typealias SupplementaryTextConfigurationBlock = (index: SupplementaryIndexType) -> TextType?
}

/// A protocol which defines the interface used by a factory to register a cell.
public protocol FactoryCellRegistrarType: AbstractFactoryType {

    /// - returns: a key used by default when there is only one cell to register
    var defaultCellKey: String { get }

    /**
     Register a cell with the factory.

     - parameter descriptor: a value which describes the cell
     - parameter view: the view in which to register.
     - parameter key: a String used to look up the registration
     - parameter configuration: a block which is used to configure the cell.
    */
    mutating func registerCell(descriptor: ReusableViewDescriptor, inView view: ViewType, withKey key: String, configuration: CellConfigurationBlock)
}

/// A protocol which defines the interface used by a factory to register a supplementary view.
public protocol FactorySupplementaryViewRegistrarType: AbstractFactoryType {

    /// - returns: a key used by default when there is only one supplementary view to register
    var defaultSupplementaryKey: String { get }

    /**
     Register a supplementary view with the factory.

     - parameter descriptor: a value which describes the view
     - parameter kind: the kind of the supplementary element
     - parameter view: the view in which to register.
     - parameter key: a String used to look up the registration
     - parameter configuration: a block which is used to configure the view.
    */
    mutating func registerSupplementaryView(descriptor: ReusableViewDescriptor, kind: SupplementaryElementKind, inView view: ViewType, withKey key: String, configuration: SupplementaryViewConfigurationBlock)
}

/// A protocol which defines the interface used by a factory to register a supplementary text.
public protocol FactorySupplementaryTextRegistrarType: AbstractFactoryType {

    /**
     Register a supplementary text.

     - parameter kind: the kind of the supplementary element
     - parameter configuration: a block which is used to configure the view.
    */
    mutating func registerSupplementaryTextWithKind(kind: SupplementaryElementKind, configuration: SupplementaryTextConfigurationBlock)
}

/// A protocol which defines how the factory vends cells.
public protocol FactoryCellVendorType: AbstractFactoryType {

    /**
     Vends a configured cell for the item at the index.

     - parameter item: the item behind the cell
     - parameter view: the containing view
     - parameter index: the index of the cell
     - returns: the configured cell
     */
    func cellForItem(item: ItemType, inView view: ViewType, atIndex index: CellIndexType) throws -> CellType
}

/// A protocol which defines how the factory vends supplementary view.
public protocol FactorySupplementaryViewVendorType: AbstractFactoryType {

    /**
     Vends a configured view for the supplementary kind.

     - parameter kind: the kind of the supplementary element
     - parameter view: the containing view
     - parameter index: the index of the cell
     - returns: the configured supplementary view
     */
    func supplementaryViewForKind(kind: SupplementaryElementKind, inView view: ViewType, atIndex index: SupplementaryIndexType) -> SupplementaryViewType?
}

/// A protocol which defines how the factory supplementary text
public protocol FactorySupplementaryTextVendorType: AbstractFactoryType {

    /**
     Vends the configured text for the supplementary kind.

     - parameter kind: the kind of the supplementary element
     - parameter index: the index of the cell
     - returns: the configured text
     */
    func supplementaryTextForKind(kind: SupplementaryElementKind, atIndex index: SupplementaryIndexType) -> TextType?
}





public protocol IndexPathIndexType {

    var indexPath: NSIndexPath { get }
}

public protocol ReusableCellBasedViewType: class {

    typealias CellType

    func registerNib(nib: UINib, withIdentifier reuseIdentifier: String)

    func registerClass(aClass: AnyClass, withIdentifier reuseIdentifier: String)

    func dequeueCellWithIdentifier(identifier: String, atIndexPath indexPath: NSIndexPath) -> CellType
}

public protocol ReusableSupplementaryViewBasedViewType: class {

    typealias SupplementaryViewType

    func registerNib(nib: UINib, forSupplementaryViewKind kind: SupplementaryElementKind, withIdentifier reuseIdentifier: String)

    func registerClass(aClass: AnyClass, forSupplementaryViewKind kind: SupplementaryElementKind, withIdentifier reuseIdentifier: String)

    func dequeueSupplementaryViewWithIdentifier(identifier: String, kind: SupplementaryElementKind, atIndexPath indexPath: NSIndexPath) -> SupplementaryViewType?
}

public protocol CellBasedViewType: ReusableCellBasedViewType, ReusableSupplementaryViewBasedViewType {

    func reloadData()
}

// MARK: - Protocol Extensions

public extension FactoryCellRegistrarType {

    /// - returns: a default implementation, which returns "Default Cell Key"
    var defaultCellKey: String {
        return "Default Cell Key"
    }

    /**
     A convencience function to register a cell when there is only one cell type needed.
     This is the a very common scenario, where all cells are the same.

     - parameter descriptor: a value which describes the cell
     - parameter view: the view in which to register.
     - parameter configuration: a block which is used to configure the cell.
     */
    mutating func registerCell(descriptor: ReusableViewDescriptor, inView view: ViewType, configuration: CellConfigurationBlock) {
        registerCell(descriptor, inView: view, withKey: defaultCellKey, configuration: configuration)
    }
}

public extension FactorySupplementaryViewRegistrarType {

    /// - returns: a default implementation, which returns "Default Suppplementary View Key"
    var defaultSupplementaryKey: String {
        return "Default Suppplementary View Key"
    }

    internal func defaultSupplementaryIndexForKind(kind: SupplementaryElementKind) -> SupplementaryElementIndex {
        return SupplementaryElementIndex(kind: kind, key: defaultSupplementaryKey)
    }

    /**
     A convencience function to register a supplementary view when there is
     only one type needed. This is the a very common scenario, where all
     headers and all the footers are the same. Note that this can be used
     only once for each element kind.

     - parameter descriptor: a value which describes the view
     - parameter kind: the kind of the supplementary element
     - parameter view: the view in which to register.
     - parameter configuration: a block which is used to configure the view.
     */
    mutating func registerSupplementaryView(descriptor: ReusableViewDescriptor, kind: SupplementaryElementKind, inView view: ViewType, configuration: SupplementaryViewConfigurationBlock) {
        registerSupplementaryView(descriptor, kind: kind, inView: view, withKey: defaultSupplementaryKey, configuration: configuration)
    }
}

// MARK: - Concrete Types

/**
 An enum type which describes the kind of supplmentary element. For
 standard headers in UITableView and UICollectionView its simplist
 to use .Header and .Footer. For arbitrary element kinds, use
 .Custom("This is my custom supplementary type") for example.
 */
public enum SupplementaryElementKind: Equatable {
    case Header
    case Footer
    case Custom(String)
}

internal struct SupplementaryElementIndex {
    let kind: SupplementaryElementKind
    let key: String
}


/**
 An enum type which encapsulates how views (or cells) should be created.

 The value is based on how the view is stored, either programmatically
 as a class, but with a reuse identifier, or inside a nib. Use dynamic
 if the view is already able to dequeue the view, such as if using
 Storyboards with prototype cells.
*/
public enum ReusableViewDescriptor {
    case DynamicWithIdentifier(String)
    case ClassWithIdentifier(AnyClass, String)
    case NibWithIdentifier(UINib, String)
}

internal extension ReusableViewDescriptor {

    var identifier: String {
        switch self {
        case let .DynamicWithIdentifier(identifier):
            return identifier
        case let .ClassWithIdentifier(_, identifier):
            return identifier
        case let .NibWithIdentifier(_, identifier):
            return identifier
        }
    }

    func registerInView<View: ReusableCellBasedViewType>(view: View) {
        switch self {
        case .DynamicWithIdentifier(_):
            break // Assumed that it's already registered
        case let .ClassWithIdentifier(aClass, identifier):
            view.registerClass(aClass, withIdentifier: identifier)
        case let .NibWithIdentifier(aNib, identifier):
            view.registerNib(aNib, withIdentifier: identifier)
        }
    }

    func registerInView<View: ReusableSupplementaryViewBasedViewType>(view: View, kind: SupplementaryElementKind) {
        switch self {
        case .DynamicWithIdentifier(_):
            break // Assumed that it's already registered
        case let .ClassWithIdentifier(aClass, identifier):
            view.registerClass(aClass, forSupplementaryViewKind: kind, withIdentifier: identifier)
        case let .NibWithIdentifier(aNib, identifier):
            view.registerNib(aNib, forSupplementaryViewKind: kind, withIdentifier: identifier)
        }
    }
}

// MARK: - Factory

public enum FactoryError: ErrorType {
    case NoCellRegisteredForKey(String)
    case InvalidCellRegisteredAtIndexPathWithIdentifier(NSIndexPath, String)
}

public class Factory<Item, Cell, SupplementaryView, View, CellIndex, SupplementaryIndex where View: CellBasedViewType, CellIndex: IndexPathIndexType, SupplementaryIndex: IndexPathIndexType>: AbstractFactoryType {

    public typealias ItemType = Item
    public typealias CellType = Cell
    public typealias SupplementaryViewType = SupplementaryView
    public typealias ViewType = View
    public typealias CellIndexType = CellIndex
    public typealias SupplementaryIndexType = SupplementaryIndex
    public typealias TextType = String

    public typealias CellConfig = (cell: Cell, item: Item, index: CellIndex) -> Void
    public typealias SupplementaryViewConfig = (supplementaryView: SupplementaryView, index: SupplementaryIndex) -> Void
    public typealias SupplementaryTextConfig = (index: SupplementaryIndex) -> String?

    public typealias GetCellKey = (item: Item, index: CellIndex) -> String

    internal typealias ReuseIdentifierType = String

    let getCellKey: GetCellKey?

    var cells = [String: (reuseIdentifier: ReuseIdentifierType, configure: CellConfig)]()
    var views = [SupplementaryElementIndex: (reuseIdentifier: ReuseIdentifierType, configure: SupplementaryViewConfig)]()
    var texts = [SupplementaryElementKind: SupplementaryTextConfig]()

    init(cell: GetCellKey? = .None) {
        getCellKey = cell
    }
}

extension Factory: FactoryCellRegistrarType {

    public func registerCell(descriptor: ReusableViewDescriptor, inView view: View, withKey key: String, configuration: CellConfig) {
        descriptor.registerInView(view)
        cells[key] = (descriptor.identifier, configuration)
    }
}

extension Factory: FactorySupplementaryViewRegistrarType {

    public func registerSupplementaryView(descriptor: ReusableViewDescriptor, kind: SupplementaryElementKind, inView view: View, withKey key: String, configuration: SupplementaryViewConfig) {
        descriptor.registerInView(view, kind: kind)
        let index = SupplementaryElementIndex(kind: kind, key: key)
        views[index] = (descriptor.identifier, configuration)
    }
}

extension Factory: FactorySupplementaryTextRegistrarType {

    public func registerSupplementaryTextWithKind(kind: SupplementaryElementKind, configuration: SupplementaryTextConfig) {
        texts[kind] = configuration
    }
}

extension Factory: FactoryCellVendorType {

    public func cellForItem(item: Item, inView view: View, atIndex index: CellIndex) throws -> Cell {

        let key = getCellKey?(item: item, index: index) ?? defaultCellKey
        let indexPath = index.indexPath

        guard let (identifier, configure) = cells[key] else {
            throw FactoryError.NoCellRegisteredForKey(key)
        }

        guard let cell = view.dequeueCellWithIdentifier(identifier, atIndexPath: indexPath) as? Cell else {
            throw FactoryError.InvalidCellRegisteredAtIndexPathWithIdentifier(indexPath, identifier)
        }

        configure(cell: cell, item: item, index: index)

        return cell
    }
}











extension SupplementaryElementKind {

    internal init(_ kind: String) {
        switch kind {
        case UICollectionElementKindSectionHeader:
            self = .Header
        case UICollectionElementKindSectionFooter:
            self = .Footer
        default:
            self = .Custom(kind)
        }
    }
}

extension SupplementaryElementKind: CustomStringConvertible {

    public var description: String {
        switch self {
        case .Header:
            return UICollectionElementKindSectionHeader
        case .Footer:
            return UICollectionElementKindSectionFooter
        case let .Custom(custom):
            return custom
        }
    }
}

extension SupplementaryElementKind: Hashable {

    public var hashValue: Int {
        return description.hashValue
    }
}

public func == (lhs: SupplementaryElementKind, rhs: SupplementaryElementKind) -> Bool {
    return lhs.description == rhs.description
}

extension SupplementaryElementIndex: Hashable {

    internal var hashValue: Int {
        return "\(kind): \(key)".hashValue
    }
}

internal func == (lhs: SupplementaryElementIndex, rhs: SupplementaryElementIndex) -> Bool {
    return (lhs.kind == rhs.kind) && (lhs.key == rhs.key)
}
