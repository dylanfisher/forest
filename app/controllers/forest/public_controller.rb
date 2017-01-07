require_dependency "forest/application_controller"

module Forest
  class PublicController < ApplicationController
    def index
      @page_title = 'Home'
    end
  end
end
