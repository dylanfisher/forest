require 'webpacker/helper'

module ApplicationHelper
  include ::Webpacker::Helper

  def current_webpacker_instance
    Forest.webpacker
  end
end
