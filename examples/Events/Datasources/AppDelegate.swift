//
//  AppDelegate.swift
//  Datasources
//
//  Created by Daniel Thorpe on 16/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import YapDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

//    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        // Override point for customization after application launch.
//        return true
//    }

}

let database = databaseNamed("Events")

private func pathToDatabase(name: String) -> String {
    var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    if let documents = paths.first as? String {
        if !documents.isEmpty {
            let filename = "\(name).sqlite"
            let path = documents.stringByAppendingPathComponent(filename)
            return path
        }
    }
    fatalError("Unable to find the documents directory")
}

private func databaseNamed(name: String) -> YapDatabase {
    return YapDatabase(path: pathToDatabase(name))
}

