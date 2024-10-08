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
  s.summary     = 'A Rails CMS.'
  s.description = 'Forest is a flexible Ruby on Rails CMS that makes maintaining an application easy for clients, and developing new applications efficient for developers.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'aws-sdk-s3'
  s.add_dependency 'aws-sdk-lambda'
  s.add_dependency 'aws-sdk-mediaconvert'
  s.add_dependency 'bootstrap', '~> 4.0'
  s.add_dependency 'cocoon'
  s.add_dependency 'csv'
  s.add_dependency 'deep_cloneable'
  s.add_dependency 'devise'
  s.add_dependency 'faraday'
  s.add_dependency 'fastimage'
  s.add_dependency 'has_scope'
  s.add_dependency 'jbuilder'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'jquery-ui-rails', '~> 6.0'
  s.add_dependency 'nokogiri'
  s.add_dependency 'ostruct'
  s.add_dependency 'pagy', '~> 7.0'
  s.add_dependency 'pundit'
  s.add_dependency 'rails'
  s.add_dependency 'redcarpet'
  s.add_dependency 'shrine', '~> 3.0'
  s.add_dependency 'simple_form'
  s.add_dependency 'uppy-s3_multipart', '~> 1.0'

  s.add_development_dependency 'pg'
end
