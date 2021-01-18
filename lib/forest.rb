require 'forest/engine'
require 'forest/migrations'
require 'devise'
require 'pundit'
require 'simple_form'

module Forest
  ROOT_PATH = Pathname.new(File.join(__dir__, ".."))
end
