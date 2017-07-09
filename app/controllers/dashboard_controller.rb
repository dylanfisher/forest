class DashboardController < ForestController
  before_action :authenticate_user!

  def index
    authorize :dashboard, :index?
    @page_title = 'Dashboard'
  end
end
