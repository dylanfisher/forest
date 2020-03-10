class PagesController < ForestController
  before_action :set_page, only: [:show]

  def show
    unless @page
      if Rails.configuration.consider_all_requests_local
        raise ActionController::RoutingError.new('Not Found')
      else
        logger.error("[Forest][Error] 404 page not found. Looked for path \"#{request.fullpath.force_encoding('utf-8')}\"")
        @body_classes ||= []
        @body_classes << 'controller--errors action--not_found'
        @page_title = '404 - Not Found'
        return render 'errors/not_found', status: 404
      end
    end
    authorize @page

    if @page.redirect.present?
      return redirect_to @page.redirect, status: 301
    end

    ensure_localization

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

    def ensure_localization
      if I18n.available_locales.length > 1
        unless request.path.match(available_locale_pattern)
          return redirect_to "/#{I18n.locale}/#{@page.path}", status: 301
        end
      else
        if request.path.match(available_locale_pattern)
          return redirect_to "/#{@page.path}", status: 301
        end
      end
    end

    def available_locale_pattern
      /^\/(#{I18n.available_locales.join('|')})(\/|$)/i
    end
end
