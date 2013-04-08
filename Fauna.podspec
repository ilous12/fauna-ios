Pod::Spec.new do |s|
  s.name         = "Fauna"
  s.version      = "0.0.1"
  s.summary      = "iOS client for Fauna service."
  s.homepage     = "http://fauna.org"
  s.license      = 'MPL'
  s.author       = { "Fauna, Inc." => "matt@fauna.org" }
  s.source       = { :git => "https://github.com/fauna/fauna-ios.git", :tag => "0.0.1" }
  s.platform     = :ios, '5.0'

  s.source_files = 'Fauna/**/*.{h,m}'

  s.public_header_files = 'Fauna/{Future,Cache,Client}/*.h', 'Fauna/*.h', 'Fauna/Categories/NSThread+FNFutureOperations.h'

  s.frameworks  = 'SystemConfiguration'
  s.libraries = 'sqlite3'

  s.requires_arc = true
end
