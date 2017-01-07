$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'forest/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'forest'
  s.version     = Forest::VERSION
  s.authors     = ['dylanfisher']
  s.email       = ['hi@dylanfisher.com']
  s.homepage    = 'https://github.com/dylanfisher/forest'
  s.summary     = 'Forest CMS'
  s.description = 'A simple and flexible CMS that grows.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 5.0.1'

  s.add_development_dependency 'pg'

  s.add_dependency 'sass-rails', '~> 5.0'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'turbolinks', '~> 5'
  s.add_dependency 'pry-rails'
  s.add_dependency 'kaminari'
  s.add_dependency 'friendly_id', '~> 5.2'
  s.add_dependency 'devise'
  s.add_dependency 'pundit'
  s.add_dependency 'bootstrap-sass', '~> 3.3.6'
  s.add_dependency 'simple_form'
  s.add_dependency 'has_scope'
  s.add_dependency 'paperclip', '~> 5.0.0'
  s.add_dependency 'jquery-fileupload-rails'
  s.add_dependency 'paper_trail'
  s.add_dependency 'cocoon'
  s.add_dependency 'faker' # Remove this eventually
end
