//
//  AppDelegate.swift
//  US Cities
//
//  Created by Daniel Thorpe on 10/05/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import YapDatabase
import YapDatabaseExtensions

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
}

let database = YapDB.databaseNamed("US_Cities")
