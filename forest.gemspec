$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "forest/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "forest"
  s.version     = Forest::VERSION
  s.authors     = ["dylanfisher"]
  s.email       = ["hi@dylanfisher.com"]
  s.homepage    = "https://github.com/dylanfisher/forest"
  s.summary     = "Forest CMS"
  s.description = "A simple and flexible CMS that grows."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.1"

  s.add_development_dependency "pg"
end
