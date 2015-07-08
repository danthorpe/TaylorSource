//
//  AppDelegate.swift
//  Gallery
//
//  Created by Daniel Thorpe on 07/07/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import FlickrKit
import YapDatabase
import YapDatabaseExtensions

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FlickrKit.sharedFlickrKit().initializeWithAPIKey("a4a892e5b83e32d4e4475f6aabac87ce", sharedSecret: "f49a1a2a7a549dc9")
        return true
    }
}

let database = YapDB.databaseNamed("Photos")
