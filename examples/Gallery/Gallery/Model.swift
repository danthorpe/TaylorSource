//
//  Model.swift
//  Gallery
//
//  Created by Daniel Thorpe on 07/07/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import MapKit

import FlickrKit
import YapDatabase
import ValueCoding
import YapDatabaseExtensions
import TaylorSource

class Photo: NSObject, NSCoding, Identifiable, Persistable {

    struct Location {
        let latitude: Double
        let longitude: Double

        var coordinate: CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        var region: MKCoordinateRegion {
            return MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        }
    }

    static let collection = "Photos"

    static var photoSize: FKPhotoSize = {
        switch UIScreen.mainScreen().scale {
        case 0...1:
            return FKPhotoSizeMedium800
        case 1...2:
            return FKPhotoSizeLarge1600
        default:
            return FKPhotoSizeLarge2048
        }
    }()

    static var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        return formatter
    }()

    static var flickrDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()


    let identifier: Identifier
    let date: NSDate
    let url: NSURL
    let title: String
    let location: Location?
    let info: String?
    let tags: String?

    private init(id: Identifier, date: NSDate, url: NSURL, title: String, location: Location? = .None, info: String? = .None, tags: String? = .None) {
        self.identifier = id
        self.date = date
        self.url = url
        self.title = title
        self.location = location
        self.info = info
        self.tags = tags
    }

    required init(coder aDecoder: NSCoder) {
        identifier = aDecoder.decodeObjectForKey("identifier") as! String
        date = aDecoder.decodeObjectForKey("date") as! NSDate
        url = aDecoder.decodeObjectForKey("url") as! NSURL
        title = aDecoder.decodeObjectForKey("title") as! String
        location = Photo.Location.decode(aDecoder.decodeObjectForKey("location"))
        info = aDecoder.decodeObjectForKey("info") as? String
        tags = aDecoder.decodeObjectForKey("tags") as? String
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(identifier, forKey: "identifier")
        aCoder.encodeObject(date, forKey: "date")
        aCoder.encodeObject(url, forKey: "url")
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(location?.encoded, forKey: "location")
        aCoder.encodeObject(info, forKey: "info")
        aCoder.encodeObject(tags, forKey: "tags")
    }
}

extension Photo.Location: ValueCoding {
    typealias Coder = PhotoLocationCoder
}

class PhotoLocationCoder: NSObject, NSCoding, CodingType {

    let value: Photo.Location

    required init(_ v: Photo.Location) {
        value = v
    }

    required init(coder aDecoder: NSCoder) {
        let latitude = aDecoder.decodeDoubleForKey("latitude")
        let longitude = aDecoder.decodeDoubleForKey("longitude")
        value = Photo.Location(latitude: latitude, longitude: longitude)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(value.latitude, forKey: "latitude")
        aCoder.encodeDouble(value.longitude, forKey: "longitude")
    }
}

// MARK: - Database Views


func photosForDate(date: NSDate) -> YapDB.Fetch {

    let grouping: YapDB.View.Grouping = .ByObject({ (_, collection, key, object) -> String! in
        if collection == Photo.collection {
            if let photo = object as? Photo {
                return Photo.dateFormatter.stringFromDate(photo.date)
            }
        }
        return .None
    })

    let sorting: YapDB.View.Sorting = .ByKey({ (_, group, collection1, key1, collection2, key2) -> NSComparisonResult in
        return .OrderedSame
    })

    let view = YapDB.View(name: Photo.collection, grouping: grouping, sorting: sorting, collections: [Photo.collection])

    return .View(view)
}

func photosForDate(date: NSDate, mappingBlock: YapDB.FetchConfiguration.MappingsConfigurationBlock? = .None) -> YapDB.FetchConfiguration {
    return YapDB.FetchConfiguration(fetch: photosForDate(date), block: mappingBlock)
}

func photosForDate(date: NSDate, mappingBlock: YapDB.FetchConfiguration.MappingsConfigurationBlock? = .None) -> Configuration<Photo> {
    return Configuration(fetch: photosForDate(date, mappingBlock: mappingBlock)) { $0 as? Photo }
}

// MARK: - API

func loadPhotos(forDate date: NSDate = NSDate(), completion: (photos: [Photo]?, error: NSError?) -> Void) {

    let flickr = FlickrKit.sharedFlickrKit()
    let interesting = FKFlickrInterestingnessGetList()
    interesting.extras = "description,geo,tags"
    interesting.date = Photo.flickrDateFormatter.stringFromDate(date)

    flickr.call(interesting) { (response, error) in
        if let error = error {
            completion(photos: .None, error: error)
        }
        else if let data = (response as NSDictionary).valueForKeyPath("photos.photo") as? [[NSObject : AnyObject]] {
            let photos = data.reduce([Photo]()) { (var acc, data) -> [Photo] in
                if let photo = Photo.createFromDictionary(data, withDate: date, usingFlickr: flickr) {
                    acc.append(photo)
                }
                return acc
            }

            completion(photos: photos, error: nil)
        }
    }
}


extension Photo {

    static func createFromDictionary(data: [NSObject : AnyObject], withDate date: NSDate, usingFlickr flickr: FlickrKit = FlickrKit.sharedFlickrKit()) -> Photo? {
        let url = flickr.photoURLForSize(Photo.photoSize, fromPhotoDictionary: data)
        if  let identifier = data["id"] as? Identifier,
            let title = data["title"] as? String {

                let location = Photo.Location.createFromDictionary(data)
                let info = (data as NSDictionary).valueForKeyPath("description._content") as? String
                let tags = data["tags"] as? String
                return Photo(id: identifier, date: date, url: url, title: title, location: location, info: info, tags: tags)
        }
        return .None
    }
}

extension Photo.Location {

    static func createFromDictionary(data: [NSObject : AnyObject]) -> Photo.Location? {
        if  let latitude = data["latitude"] as? NSNumber,
            let longitude = data["longitude"] as? NSNumber {
                if latitude.doubleValue != 0.000 && longitude.doubleValue != 0.000 {
                    return Photo.Location(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
                }
        }
        return .None
    }
}







