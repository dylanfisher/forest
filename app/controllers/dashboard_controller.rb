class DashboardController < ForestController
  before_action :authenticate_user!

  def index
    authorize :dashboard, :index?
    resources = [Page, Menu, MediaItem, Setting, User, UserGroup]
    @resources = resources.sort_by(&:name)
    @page_title = 'Dashboard'
  end
end
