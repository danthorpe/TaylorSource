# 0.11.0
1. [[TAY-12](https://github.com/danthorpe/TaylorSource/pull/12)]: Modifies [TableView|CollectionView]DataSourceProviders to access arguments of DatasourceProviderType instead of DatasourceType. This allows for improved composition and code re-use.


# 0.10.0
1. [[TAY-5](https://github.com/danthorpe/TaylorSource/pull/5)]: Adopts Quick BDD testing framework, adds coverage to YapDB Observer & Datasource.
1. [[TAY-7](https://github.com/danthorpe/TaylorSource/pull/7)]: Simplifies the common case of having a factory with a single cell type. In such a scenario, initialization of the Factory class requires no key closures, and cell/view registration takes no key parameter.
1. [[TAY-10](https://github.com/danthorpe/TaylorSource/pull/10)]: StaticDatasource and YapDBDatasource now expose an API for registering supplementary text values. This is used automatically for header and footer titles by the UITableViewDatasourceProvider.
1. [[TAY-11](https://github.com/danthorpe/TaylorSource/pull/11)]: Adds another example project (US Cities) which uses TaylorSource & YapDatabase.