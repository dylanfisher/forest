require_relative "lib/forest/version"

Gem::Specification.new do |spec|
  spec.name        = "forest"
  spec.version     = Forest::VERSION
  spec.authors     = [ "dylanfisher" ]
  spec.email       = [ "hi@dylanfisher.com" ]
  spec.homepage    = "TODO"
  spec.summary     = "TODO: Summary of Forest."
  spec.description = "TODO: Description of Forest."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.1"

  # Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
  spec.add_dependency "bcrypt", "~> 3.1.7"
end
