class PagesController < ForestController
  before_action :set_page, only: [:show]

  def show
    unless @page
      check_for_redirect! and return

      if Rails.configuration.consider_all_requests_local
        raise ActionController::RoutingError.new('Not Found')
      else
        skip_authorization
        logger.error("[Forest][Warn] 404 page not found. Looked for path \"#{request.fullpath.force_encoding('utf-8')}\"")
        @html_classes ||= []
        @html_classes << 'controller--errors action--not_found'
        @page_title = '404 - Not Found'
        return render 'errors/not_found', status: 404
      end
    end

    authorize @page

    if @page.redirect.present?
      return redirect_to @page.redirect, status: 301
    elsif @page.path != page_path
      return redirect_to "/#{@page.path}", params: { page_path: @page.path }, status: 301
    end

    ensure_localization

    @html_classes << "page--#{@page.slug}"
  end

  def edit
    skip_authorization
    @page = Page.where(path: params[:page_path]).try(:first)
    if @page
      return redirect_to edit_admin_page_path(@page)
    else
      return redirect_to admin_pages_path
    end
  end

  private

  # Override in your host app if you don't want to force a default locale
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
