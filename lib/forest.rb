require 'forest/engine'
require 'forest/migrations'
require 'devise'
require 'pundit'
require 'simple_form'
require 'paperclip'

module Forest
  class Application < Rails::Application
    config.forest_application_cache_key = SecureRandom.uuid
  end
end
