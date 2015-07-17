# 0.14.0
1. [[TAY-18](https://github.com/danthorpe/TaylorSource/pull/18)]: Supports the optional editing methods in `UITableViewDataSource` via optional closures in `DatasourceProviderType`.
2. [[TAY-20](https://github.com/danthorpe/TaylorSource/pull/20)]: Supports Sliceable on Observer, Mapper and YapDatabaseViewMappings.

# 0.13.0
1. [[TAY-17](https://github.com/danthorpe/TaylorSource/pull/17)]: Added a bitter badge to the README.
1. [[TAY-2](https://github.com/danthorpe/TaylorSource/pull/2)]: Improvements to the README for multiple cells and models.
1. [[TAY-16](https://github.com/danthorpe/TaylorSource/pull/16)]: Adds another example project which demonstrates usage of different cell classes in the same datasource.
2. 
# 0.12.0
1. [[TAY-13](https://github.com/danthorpe/TaylorSource/pull/13)]: Make a few subtle changes to increase the ease of implementing DatasourceType from scratch outside of TaylorSource. No longer is a SequenceType and CollectionType implementation required. And `YapDBCellIndex` and `YapDBSupplementaryViewIndex` have public constructors.
1. [[TAY-15](https://github.com/danthorpe/TaylorSource/pull/15)]: Preparing for Xcode 7 and Swift 2.0, this PR refactors the project structure, so that there is a framework project with tests, and example projects which build the framework using Pods. The Datasources and US Cities have been moved into the examples project.

# 0.11.0
1. [[TAY-12](https://github.com/danthorpe/TaylorSource/pull/12)]: Modifies [TableView|CollectionView]DataSourceProviders to access arguments of DatasourceProviderType instead of DatasourceType. This allows for improved composition and code re-use.


# 0.10.0
1. [[TAY-5](https://github.com/danthorpe/TaylorSource/pull/5)]: Adopts Quick BDD testing framework, adds coverage to YapDB Observer & Datasource.
1. [[TAY-7](https://github.com/danthorpe/TaylorSource/pull/7)]: Simplifies the common case of having a factory with a single cell type. In such a scenario, initialization of the Factory class requires no key closures, and cell/view registration takes no key parameter.
1. [[TAY-10](https://github.com/danthorpe/TaylorSource/pull/10)]: StaticDatasource and YapDBDatasource now expose an API for registering supplementary text values. This is used automatically for header and footer titles by the UITableViewDatasourceProvider.
1. [[TAY-11](https://github.com/danthorpe/TaylorSource/pull/11)]: Adds another example project (US Cities) which uses TaylorSource & YapDatabase.