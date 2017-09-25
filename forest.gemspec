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
  s.summary     = 'A CMS that grows.'
  s.description = 'Forest is a flexible Ruby on Rails CMS that makes maintaining an application easy, and developing new applications efficient and fun.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails'

  s.add_development_dependency 'pg'

  s.add_dependency 'aws-sdk', '~> 2'
  s.add_dependency 'bootstrap-sass'
  s.add_dependency 'cocoon'
  s.add_dependency 'devise'
  s.add_dependency 'has_scope'
  s.add_dependency 'jquery-fileupload-rails'
  s.add_dependency 'jquery-ui-rails'
  s.add_dependency 'kaminari'
  s.add_dependency 'nokogiri'
  s.add_dependency 'paperclip'
  s.add_dependency 'pundit'
  s.add_dependency 'redcarpet'
  s.add_dependency 'sass-rails'
  s.add_dependency 'simple_form'
  s.add_dependency 'turbolinks'
end
