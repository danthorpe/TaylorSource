
public struct NSFRCCellIndex: IndexPathIndexType {
    public let indexPath: NSIndexPath
    public let selected: Bool?
    
    public init(indexPath: NSIndexPath, selected: Bool? = .None) {
        self.indexPath = indexPath
        self.selected = selected
    }
}

public struct NSFRCSupplementaryIndex: IndexPathIndexType {
    public let group: String
    public let indexPath: NSIndexPath
    
    public init(group: String, indexPath: NSIndexPath) {
        self.group = group
        self.indexPath = indexPath
    }
}

public class NSFRCFactory<
    Item, Cell, SupplementaryView, View
    where
View: CellBasedView>: Factory<Item, Cell, SupplementaryView, View, NSFRCCellIndex, NSFRCSupplementaryIndex> {
    
    public override init(cell: GetCellKey? = .None, supplementary: GetSupplementaryKey? = .None) {
        super.init(cell: cell, supplementary: supplementary)
    }
}

