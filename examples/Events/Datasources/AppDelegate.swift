//
//  AppDelegate.swift
//  Datasources
//
//  Created by Daniel Thorpe on 16/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit

import YapDatabase
import YapDatabaseExtensions

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
}

let database = YapDB.databaseNamed("Events")

