//
//  DataSourceProvider.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 28/03/2016.
//
//

import Foundation

/**
 DataSourceProvider is a protocol allows a type to provide
 a specialized DataSource (something conforming to DataSourceType).

 This definition is used to compose a DataSource into concrete
 types which then provide specific data sources, such as
 UITableViewDataSource, yet maintain full type fidelity of the
 underlying datasource.
 */
public protocol DataSourceProviderType {

    /// The associated datasource type
    associatedtype DataSource: DataSourceType

    /// The associated editor type
    associatedtype Editor: DataSourceEditorType

    /// - returns: the datasource
    var dataSource: DataSource { get }

    /// - returns: the editor
    var editor: Editor { get }
}

