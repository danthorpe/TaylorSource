Pod::Spec.new do |s|
  s.name              = "TaylorSource"
  s.version           = "0.15.2"
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
    ss.source_files   = 'TaylorSource/Base/*.{m,h,swift}'
  end

  s.subspec 'YapDatabase' do |ss|
    ss.dependency 'TaylorSource/Base'
    ss.dependency 'YapDatabase', '~> 2.7'
    ss.dependency 'YapDatabaseExtensions', '~> 2'
    ss.source_files   = 'TaylorSource/YapDatabase/*.{m,h,swift}'    
  end
end

