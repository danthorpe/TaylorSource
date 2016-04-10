//
//  Created by Daniel Thorpe on 20/04/2015.
//

import Foundation

/**
 An abstract protocol which defines the associated
 view type in use by FactoryType in TaylorSource.
*/
public protocol ViewFactoryType {

    /// The type of the containing view, which must be based around cells,
    /// i.e. UITableView, UICollectionView or subclass
    associatedtype View: CellBasedViewType
}

/// A protocol which defines the interface used by a factory to register a cell.
public protocol FactoryCellRegistrarType: ViewFactoryType {

    /// The type of the cell - i.e. custom cell class
    associatedtype Cell

    /// The type of the cell index, used to associate additional metadata
    /// with the index
    associatedtype CellIndex: ConfigurationIndexType

    /// The type of the model item behind each cell
    associatedtype Item

    /// The type of the block used to configure cells
    associatedtype CellConfigurationBlock = (cell: Cell, item: Item, index: ConfigurationIndexType) -> Void

    /// - returns: a key used by default when there is only one cell to register
    var defaultCellKey: String { get }

    /**
     Register a cell with the factory.

     - parameter descriptor: a value which describes the cell
     - parameter view: the view in which to register.
     - parameter key: a String used to look up the registration
     - parameter configuration: a block which is used to configure the cell.
    */
    mutating func registerCell(descriptor: ReusableViewDescriptor, inView view: View, withKey key: String, configuration: CellConfigurationBlock)
}

/// A protocol which defines how the factory vends cells.
public protocol FactoryCellVendorType: FactoryCellRegistrarType {

    /**
     Vends a configured cell for the item at the index.

     - parameter item: the item behind the cell
     - parameter view: the containing view
     - parameter index: the index of the cell
     - returns: the configured cell
     */
    func cellForItem(item: Item, inView view: View, atIndex index: CellIndex) throws -> Cell
}

/// A protocol which defines the interface used by a factory to register a supplementary view.
public protocol FactorySupplementaryViewRegistrarType: ViewFactoryType {

    /// The type of the supplementary view
    associatedtype SupplementaryView

    /// The type of the supplementary (i.e. header) index, used to
    /// associate additional metadata with the index
    associatedtype SupplementaryIndex: ConfigurationIndexType

    /// The type of the block used to configure supplementary views
    associatedtype SupplementaryViewConfigurationBlock = (supplementaryView: SupplementaryView, index: View.SupplementaryIndex) -> Void

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
    mutating func registerSupplementaryView(descriptor: ReusableViewDescriptor, kind: SupplementaryElementKind, inView view: View, withKey key: String, configuration: SupplementaryViewConfigurationBlock)
}

/// A protocol which defines how the factory vends supplementary view.
public protocol FactorySupplementaryViewVendorType: FactorySupplementaryViewRegistrarType {

    /**
     Vends a configured view for the supplementary kind.

     - parameter kind: the kind of the supplementary element
     - parameter view: the containing view
     - parameter index: the index of the cell
     - returns: the configured supplementary view
     */
    func supplementaryViewForKind(kind: SupplementaryElementKind, inView view: View, atIndex index: SupplementaryIndex) -> SupplementaryView?
}

/// A protocol which defines the interface used by a factory to register a supplementary text.
public protocol FactorySupplementaryTextRegistrarType: FactorySupplementaryViewRegistrarType {

    /// The type of any associated text, e.g. String, or NSAttributedString
    associatedtype Text

    /// The type of the block used to configure/get supplementary text
    associatedtype SupplementaryTextConfigurationBlock = (index: SupplementaryIndex) -> Text?

    /**
     Register a supplementary text.

     - parameter kind: the kind of the supplementary element
     - parameter configuration: a block which is used to configure the view.
     */
    mutating func registerSupplementaryTextWithKind(kind: SupplementaryElementKind, configuration: SupplementaryTextConfigurationBlock)
}

/// A protocol which defines how the factory supplementary text
public protocol FactorySupplementaryTextVendorType: FactorySupplementaryTextRegistrarType {

    /**
     Vends the configured text for the supplementary kind.

     - parameter kind: the kind of the supplementary element
     - parameter index: the index of the cell
     - returns: the configured text
     */
    func supplementaryTextForKind(kind: SupplementaryElementKind, atIndex index: SupplementaryIndex) -> Text?
}

/**
 FactoryType is a protocol collection. It is used to define the interface for factories in
 TaylorSource. Factories are used to manage cell based views. These are views, such as UITableView,
 which dequeue other views to display content. 
 
 The Factory uses generics to defines the types of the Cell, the Item which is a view model used 
 to display each Cell, the CellIndex which defines how where in the View the Cell appears.
 
 Similarly, the View will likely have SupplementaryView capabilities, which are views which appear
 in the view, such as headers and footers. SupplementaryIndex defines their location in the View.
 
 Finally, a view may support supplementary text of type Text. 
 */
public typealias FactoryType = protocol<FactoryCellVendorType, FactorySupplementaryViewVendorType, FactorySupplementaryTextVendorType>



public protocol ReusableCellBasedViewType: class {

    associatedtype Cell
    associatedtype CellIndex

    func registerNib(nib: UINib, withIdentifier reuseIdentifier: String)

    func registerClass(aClass: AnyClass, withIdentifier reuseIdentifier: String)

    func dequeueCellWithIdentifier(identifier: String, atIndexPath indexPath: CellIndex) -> Cell
}

public protocol ReusableSupplementaryViewBasedViewType: class {

    associatedtype SupplementaryView
    associatedtype SupplementaryIndex

    func registerNib(nib: UINib, forSupplementaryViewKind kind: SupplementaryElementKind, withIdentifier reuseIdentifier: String)

    func registerClass(aClass: AnyClass, forSupplementaryViewKind kind: SupplementaryElementKind, withIdentifier reuseIdentifier: String)

    func dequeueSupplementaryViewWithIdentifier(identifier: String, kind: SupplementaryElementKind, atIndexPath indexPath: SupplementaryIndex) -> SupplementaryView?
}

public protocol CellBasedViewType: ReusableCellBasedViewType, ReusableSupplementaryViewBasedViewType {

    func reloadData()
}

/// A protocol to expose a reuse identifier for cells and views.
public protocol ReusableElementType {

    /// - returns: a String property
    static var reuseIdentifier: String { get }
}

/// A protocol to expose a nib for a view.
public protocol ReusableViewType: class, ReusableElementType {

    /// - returns: a UINib property
    static var nibName: String { get }
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
    mutating func registerCell(descriptor: ReusableViewDescriptor, inView view: View, configuration: CellConfigurationBlock) {
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
    mutating func registerSupplementaryView(descriptor: ReusableViewDescriptor, kind: SupplementaryElementKind, inView view: View, configuration: SupplementaryViewConfigurationBlock) {
        registerSupplementaryView(descriptor, kind: kind, inView: view, withKey: defaultSupplementaryKey, configuration: configuration)
    }
}

public extension ReusableViewType {

    static var nibName: String {
        return "\(self)"
    }

    static var nib: UINib {
        return UINib(nibName: nibName, bundle: NSBundle(forClass: self))
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

internal extension SupplementaryElementKind {

    init(_ kind: String) {
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

internal struct SupplementaryElementIndex {
    let kind: SupplementaryElementKind
    let key: String
}

extension SupplementaryElementIndex: Hashable {

    internal var hashValue: Int {
        return "\(kind): \(key)".hashValue
    }
}

internal func == (lhs: SupplementaryElementIndex, rhs: SupplementaryElementIndex) -> Bool {
    return (lhs.kind == rhs.kind) && (lhs.key == rhs.key)
}
