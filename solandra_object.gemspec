$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "solandra_object/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "solandra_object"
  s.version     = SolandraObject::VERSION
  s.authors     = ["Jason M. Kusar"]
  s.email       = ["jason@kusar.net"]
  s.homepage    = "https://github.com/jkusar/solandra_object"
  s.summary     = "Cassandra Object with Sunspot Rails integrated to provide search capabilities"
  s.description = "Cassandra Object with Sunspot Rails integrated to provide search capabilities.  Intended for use with Solandra but should work with any SOLR."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2.1"
  s.add_dependency "jkusar-cassandra_object", "~> 2.8.8"
  s.add_dependency "sunspot_rails", "~> 1.3.0"

  s.add_development_dependency "rspec-rails", "~> 2.8.0"
  s.add_development_dependency "ruby-debug"
  s.add_development_dependency "rcov"
end
