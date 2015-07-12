//
//  ViewController.swift
//  Gallery
//
//  Created by Daniel Thorpe on 07/07/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import MapKit

import FlickrKit
import Haneke
import YapDatabase
import YapDatabaseExtensions
import TaylorSource


// MARK: - Cell Classes

class BasicPhotoCell: UITableViewCell, ReusableView {

    class var reuseIdentifier: String {
        return "BasicPhotoCell"
    }

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    class func configuration() -> GalleryDatasource.Datasource.FactoryType.CellConfiguration {
        return { (cell, photo, index) in
            cell.titleLabel.text = photo.title
            println("fetching image: \(photo.url)")
            cell.photoImageView.hnk_setImageFromURL(photo.url)
        }
    }

    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.hnk_cancelSetImage()
        photoImageView.image = nil
    }
}

class PhotoCellWithLabel: BasicPhotoCell, ReusableView {

    override class var reuseIdentifier: String {
        return "PhotoCellWithLabel"
    }

    override class func configuration() -> GalleryDatasource.Datasource.FactoryType.CellConfiguration {
        let parent = super.configuration()
        return { (cell, photo, index) in
            parent(cell: cell, item: photo, index: index)

            if let cell = cell as? PhotoCellWithLabel, let tags = photo.tags {
                cell.infoLabel.text = tags
            }
        }
    }

    @IBOutlet var infoLabel: UILabel!
}

class PhotoCellWithMap: BasicPhotoCell, ReusableView {

    override class var reuseIdentifier: String {
        return "PhotoCellWithMap"
    }

    override class func configuration() -> GalleryDatasource.Datasource.FactoryType.CellConfiguration {
        let parent = super.configuration()
        return { (cell, photo, index) in
            parent(cell: cell, item: photo, index: index)
            if let cell = cell as? PhotoCellWithMap, let location = photo.location {

                let options = MKMapSnapshotOptions()
                options.region = location.region
                cell.snapshotter = MKMapSnapshotter(options: options)
                cell.snapshotter!.startWithCompletionHandler { (snapshot, error) in
                    if let snapshot = snapshot {
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.mapImageView.image = snapshot.image
                        }
                    }
                    else if let error = error {
                        println("error: \(error)")
                    }
                }
            }
        }
    }

    @IBOutlet var mapImageView: UIImageView!
    var snapshotter: MKMapSnapshotter?

    override func prepareForReuse() {
        super.prepareForReuse()
        snapshotter?.cancel()
    }
}

extension Photo {

    enum CellKey: String {
        case Basic = "basic"
        case WithInfo = "with info"
        case WithTags = "with tags"
        case WithLocation = "with location"
    }

    static var getCellKey: GalleryDatasource.Datasource.FactoryType.GetCellKey {
        return { (photo, index) -> String in
            if photo.tags != nil {
                return CellKey.WithTags.rawValue
            }
            else if photo.location != nil {
                return CellKey.WithLocation.rawValue
            }
            else {
                return CellKey.Basic.rawValue
            }
        }
    }
}

/**

This example code demonstrates how multiple cell classes, with a common ancestor can
be registered with the same factory.

It also demonstrates some best practices:

1. Use of a bespoke type as a datasource provider

2. Defined typealiases inside the provider for its DatasourceType (and Factory) - this allows
us to take advantage of TaylorSource's types. e.g. 
GalleryDatasource.Datasource.FactoryType.CellConfiguration is the cell closure type.

3. Move computation of the GetCellKey to an extension on the model type - note the construction 
of the Factory. Also, use String backed enums to avoid stringly typing the keys.

4. Design cells in Xibs using Interface Builder. All of these cells have the following 
convention. The class name is also the Xib name, and the reuse identifier (which is set in the Xib).
This makes the implementation of `ReusableView` very simple, and avoids unnecessary strings.

5. Take advantage of base cell configuration code. Capture the cell configuration block of the 
super class inside the closure. See `PhotoCellWithLabel` etc.

6. The view controller only needs a reference to the table view datasource provider, but our 
custome bespoke provider is accessible (and correctly typed) via the `provider` property. This
can be useful as custom logic can be put into your provider. See the use of the `date` property
in `viewDidLoad` below.

7. Standard practice of configuring the datasource inside the `viewDidLoad` method. In 
general this will always be something like....

    wrapper = SomeGenericProvider(YourCustomDatasource(foo: bar, view: cellBasedView))
    cellBasedView.dataSource = wrapper.genericDataSource

8. I've not covered adding supplementary views, but they're basically just the same as the cells.

9. Another good technique, which I've not covered here, is that the cell configuration function
is not a protocol definition, just the return type is defined. Therefore, your custom datasource
can provide helper objects to the closure. Generally these are things which you don't want to
create inside the block, e.g. `NSFormatter` objects, for example - create an NSDateFormatter in
the datasource, and then inject it into your cell configuration block...

    static func cellConfiguration(withFormatter formatter: NSDateFormatter) -> MyDatasourceProvider.Datasource.FactoryType.CellConfiguration {
        return { (cell, item, index) in 
            // can use formatter here.
        }
    }

10. If you need to implement a table view (or collection view) delegate, this can still be done
with a specialized object, often best owned by the custom datasource.

**/


class GalleryDatasource: DatasourceProviderType {

    typealias Factory = YapDBFactory<Photo, BasicPhotoCell, UITableViewHeaderFooterView, UITableView>
    typealias Datasource = YapDBDatasource<Factory>

    var datasource: Datasource
    var date: NSDate

    init(date: NSDate, db: YapDatabase, view: Datasource.FactoryType.ViewType) {

        self.date = date
        datasource = Datasource(
            id: "gallery datasource",
            database: db,
            factory: Factory(cell: Photo.getCellKey),
            processChanges: view.processChanges,
            configuration: photosForDate(date))

        datasource.factory.registerCell(
            .NibWithIdentifier(BasicPhotoCell.nib, BasicPhotoCell.reuseIdentifier),
            inView: view,
            withKey: Photo.CellKey.Basic.rawValue,
            configuration: BasicPhotoCell.configuration())

        datasource.factory.registerCell(
            .NibWithIdentifier(PhotoCellWithLabel.nib, PhotoCellWithLabel.reuseIdentifier),
            inView: view,
            withKey: Photo.CellKey.WithTags.rawValue,
            configuration: PhotoCellWithLabel.configuration())

        datasource.factory.registerCell(
            .NibWithIdentifier(PhotoCellWithMap.nib, PhotoCellWithMap.reuseIdentifier),
            inView: view,
            withKey: Photo.CellKey.WithLocation.rawValue,
            configuration: PhotoCellWithMap.configuration())
    }
}

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var wrapper: BasicTableViewDataSourceProvider<GalleryDatasource>!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatasource()
        loadPhotos(forDate: wrapper.provider.date) { (photos, error) in
            if let photos = photos {
                database.write(photos)
            }
            else if let error = error {
                println("Error: \(error)")
            }
        }
    }

    func configureDatasource() {
        let date = NSDate().dateByAddingTimeInterval(-172_800.0)
        wrapper = BasicTableViewDataSourceProvider(GalleryDatasource(date: date, db: database, view: tableView))
        tableView.dataSource = wrapper.tableViewDataSource
        tableView.estimatedRowHeight = 256.0
    }
}

