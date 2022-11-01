Pod::Spec.new do |spec|
  spec.name         = 'SwiftGraphQL'
  spec.homepage     = 'https://swift-graphql.com'
  spec.authors      = { 'Matic Zavadlal' => 'matic.zavadlal@gmail.com' }
  spec.summary      = 'GraphQL query generator and client for Swift'
  spec.license      = { :type => 'MIT' }

  spec.version      = '4.0.3'
  spec.source       = { 
		:git => 'https://github.com/maticzav/swift-graphql.git', 
		:tag => spec.version.to_s 
	}

  spec.source_files  = "Sources/**/*.swift"

	s.deprecated = true
  s.deprecated_in_favor_of = "Swift Package Manager"
end