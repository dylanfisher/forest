class PagesController < ForestController
  before_action :set_page, only: [:show]

  def show
    unless @page
      if Rails.configuration.consider_all_requests_local
        raise ActionController::RoutingError.new('Not Found')
      else
        logger.error("[Forest][Error] 404 page not found. Looked for path \"#{request.fullpath}\"")
        @body_classes ||= []
        @body_classes << 'controller--errors action--not_found'
        @page_title = '404 - Not Found'
        return render 'errors/not_found'
      end
    end
    authorize @page

    if @page.redirect.present?
      return redirect_to @page.redirect
    end

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
