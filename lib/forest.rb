require 'forest/engine'
require 'forest/migrations'
require 'devise'
require 'pundit'
require 'simple_form'

module Forest
  ROOT_PATH = Pathname.new(File.join(__dir__, ".."))

  mattr_accessor :image_derivative_thumb_size
  @@image_derivative_thumb_size = 200

  mattr_accessor :image_derivative_small_size
  @@image_derivative_small_size = 600

  mattr_accessor :image_derivative_medium_size
  @@image_derivative_medium_size = 1200

  mattr_accessor :image_derivative_large_size
  @@image_derivative_large_size = 2200

  # Configure forest's default values in an initializer in your host app.
  # Forest.setup do |config|
  #   config.image_derivative_large_size = 3000
  # end
  def self.setup
    yield self
  end
end
