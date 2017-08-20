class Admin::DashboardController < Admin::ForestController
  def index
    authorize :dashboard, :index?
    @page_title = 'Dashboard'
  end
end
