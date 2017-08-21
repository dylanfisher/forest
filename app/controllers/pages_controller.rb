class PagesController < ForestController
  before_action :set_page, only: [:show]

  def show
    unless @page
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  private

    def set_page
      @page = Page.find_by_path(params[:page_path])
    end
end
