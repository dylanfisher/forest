require_dependency "forest/application_controller"

module Forest
  class AdminController < ApplicationController
    before_action :authenticate_user!

    RESOURCES = [Page, Menu, MediaItem, Setting, User, UserGroup]

    def index
      authorize :dashboard, :index?
      @resources = RESOURCES.sort_by(&:name)
      @page_title = 'Dashboard'
    end
  end
end
