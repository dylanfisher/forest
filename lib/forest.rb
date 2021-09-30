require 'forest/engine'
require 'forest/migrations'
require 'devise'
require 'pundit'
require 'simple_form'

module Forest
  ROOT_PATH = Pathname.new(File.join(__dir__, ".."))

  # Override the devise_for routes.rb declaration in a host app if necessary
  mattr_accessor :override_devise_for_route_declaration
  @@override_devise_for_route_declaration = false

  # Each of the thumb, small, medium and large derivatives are used by Forest CMS in the
  # admin area, but these options can be changed, and additional derivatives can be
  # added via the host app if necessary.
  mattr_accessor :image_derivative_thumb_options
  @@image_derivative_thumb_options = {
    resize: {
      width: 200, height: 200, fit: 'cover', withoutEnlargement: true
    },
    jpeg: {
      quality: 60, trellisQuantisation: true, overshootDeringing: true, optimiseScans: true, progressive: true, quantisationTable: 3
    },
    sharpen: true
  }

  mattr_accessor :image_derivative_small_options
  @@image_derivative_small_options = {
    resize: {
      width: 600, height: 600, fit: 'inside', withoutEnlargement: true
    },
    jpeg: {
      quality: 60, trellisQuantisation: true, overshootDeringing: true, optimiseScans: true, progressive: true, quantisationTable: 3, chromaSubsampling: '4:4:4'
    },
    sharpen: true
  }

  mattr_accessor :image_derivative_medium_options
  @@image_derivative_medium_options = {
    resize: {
      width: 1200, height: 1200, fit: 'inside', withoutEnlargement: true
    },
    jpeg: {
      quality: 70, trellisQuantisation: true, overshootDeringing: true, optimiseScans: true, progressive: true, quantisationTable: 3, chromaSubsampling: '4:4:4'
    },
    sharpen: true
  }

  mattr_accessor :image_derivative_large_options
  @@image_derivative_large_options = {
    resize: {
      width: 2200, height: 1600, fit: 'inside', withoutEnlargement: true
    },
    jpeg: {
      quality: 70, trellisQuantisation: true, overshootDeringing: true, optimiseScans: true, progressive: true, quantisationTable: 3, chromaSubsampling: '4:4:4'
    }
  }

  # Configure forest's default values in an initializer in your host app.
  # Forest.setup do |config|
  #   config.image_derivative_large_options[:resize][:width] = 3000
  #   config.image_derivative_large_options[:resize][:height] = 3000
  #   config.image_derivative_large_options[:jpeg][:quality] = 90
  # end
  def self.setup
    yield self
  end
end
