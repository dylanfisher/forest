class PagesController < ForestController
  before_action :set_page, only: [:show]

  def show
    unless @page
      raise ActionController::RoutingError.new('Not Found')
    end
    authorize @page

    @body_classes << "page--#{@page.slug}"
  end

  def edit
    @page = Page.where(path: params[:page_path]).try(:first)
    if @page
      return redirect_to edit_admin_page_path(@page)
    else
      return redirect_to admin_pages_path
    end
  end

  private

    def set_page
      @page = Page.find_by_path(params[:page_path].presence || 'home')
    end
end
