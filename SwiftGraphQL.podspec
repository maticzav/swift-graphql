Pod::Spec.new do |s|
  s.name         = "SwiftGraphQL"
  s.version      = "2.2.1"
  s.summary      = "A GraphQL client that lets you forget about GraphQL."
  s.description  = <<-DESC
    SwiftGraphQL is a Swift code generator and a lightweight GraphQL client. It lets you create queries using Swift, and guarantees that every query you create is valid.
  DESC
  s.homepage     = "https://github.com/maticzav/swift-graphql"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Matic Zavadlal" => "matic.zavadlal@gmail.com" }
  s.social_media_url   = "https://twitter.com/maticzav"
  s.ios.deployment_target = "13.0"
  s.osx.deployment_target = "10.15"
  s.tvos.deployment_target = "13.0"
  s.watchos.deployment_target = "6.0"
  s.source       = { :git => "https://github.com/johnsundell/files.git", :tag => s.version.to_s }
  # Please let us know if only these sources are needed
  s.source_files  = "Sources/SwiftGraphQL/**/*"
  # Probably needs also more dependencies seen your SPM
  s.frameworks  = "Foundation"
end