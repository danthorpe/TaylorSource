Pod::Spec.new do |s|
  s.name              = "TaylorSource"
  s.version           = "0.14.1"
  s.summary           = "Generic table view & collection view datasources in Swift, for use with YapDatabase."
  s.description       = <<-DESC
  
  Provides static datasource and view factory for simple 
  table views and collection views. However, real
  power comes from using YapDatabase & YapDatabaseExtensions, 
  to get database driven, auto-updating table
  and collection view data sources.

                       DESC
  s.homepage          = "https://github.com/danthorpe/TaylorSource"
  s.license           = 'MIT'
  s.author            = { "Daniel Thorpe" => "@danthorpe" }
  s.source            = { :git => "https://github.com/danthorpe/TaylorSource.git", :tag => s.version.to_s }
  s.module_name       = 'TaylorSource'
  s.social_media_url  = 'https://twitter.com/danthorpe'
  s.requires_arc      = true
  s.platform          = :ios, '8.0'
  s.default_subspec   = 'Base'

  s.subspec 'Base' do |ss|
    ss.source_files   = 'framework/TaylorSource/Base/*.{swift,m,h}'
  end

  s.subspec 'YapDatabase' do |ss|
    ss.dependency 'TaylorSource/Base'
    ss.dependency 'YapDatabase', '~> 2'
    ss.dependency 'YapDatabaseExtensions', '~> 1'
    ss.source_files   = 'framework/TaylorSource/YapDatabase/*.{m,h,swift}'    
  end
end

