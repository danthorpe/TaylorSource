//
//  IndexType.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 10/04/2016.
//  Copyright © 2016 Daniel Thorpe. All rights reserved.
//

import Foundation

/**
 A abstract protocol to associate indexes expected by views and
 datasources, with the ability to include additional properties
 used to perform configuration.
 */
public protocol ConfigurationIndexType: Equatable {

    /// The index used by the view, e.g. NSIndexPath
    associatedtype ViewIndex

    /// - returns: the index in the view
    var indexInView: ViewIndex { get }
}

public protocol IndexPathIndexType: Equatable {

    var indexPath: NSIndexPath { get }
}

