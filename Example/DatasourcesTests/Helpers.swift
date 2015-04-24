//
//  Created by Daniel Thorpe on 19/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import YapDatabase

func createYapDatabase(file: String, suffix: String? = .None) -> YapDatabase {

    func pathToDatabase(name: String, suffix: String? = .None) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let directory: String = (paths.first as? String) ?? NSTemporaryDirectory()
        let filename: String = {
            if let suffix = suffix {
                return "\(name)-\(suffix).sqlite"
            }
            return "\(name).sqlite"
        }()
        return directory.stringByAppendingPathComponent(filename)
    }

    let path = pathToDatabase(file.lastPathComponent, suffix: suffix?.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "()")))
    NSFileManager.defaultManager().removeItemAtPath(path, error: nil)

    return YapDatabase(path: path)
}

class StubbedTableView: UITableView {
    override func dequeueCellWithIdentifier(id: String, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell(style: .Default, reuseIdentifier: id)
    }

    override func dequeueReusableHeaderFooterViewWithIdentifier(identifier: String) -> AnyObject? {
        return UITableViewHeaderFooterView(reuseIdentifier: identifier)
    }
}

class StubbedCollectionView: UICollectionView {
    override func dequeueCellWithIdentifier(id: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return UICollectionViewCell()
    }

    override func dequeueReusableSupplementaryViewOfKind(elementKind: String, withReuseIdentifier identifier: String, forIndexPath indexPath: NSIndexPath!) -> AnyObject {
        return UICollectionReusableView()
    }
}

