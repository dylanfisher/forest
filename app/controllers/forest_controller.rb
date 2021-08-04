class ForestController < ApplicationController
  include Pundit

  protect_from_forgery with: :exception, prepend: true
  skip_before_action :verify_authenticity_token, if: -> { controller_name == 'sessions' && action_name == 'create' }

  layout :layout_by_resource

  before_action :set_html_classes

  def after_sign_in_path_for(resource)
    main_app.admin_path
  end

  private

  def layout_by_resource
    devise_controller? ? 'devise' : 'application'
  end

  def set_html_classes
    controller_heirarchy = self.class.name.split('::').reject(&:blank?)
    controller_heirarchy.pop
    controller_heirarchy = controller_heirarchy.collect { |a| "controller-class--#{a.underscore}" }.join(' ')

    @html_classes ||= []
    @html_classes << controller_heirarchy
    @html_classes << "controller--#{controller_name}"
    @html_classes << "action--#{action_name}"
    @html_classes << 'current-user--admin' if current_user&.admin?
  end

  def home_page_paths
    ['/', '/home'].concat(I18n.available_locales.collect { |l| "/#{l}" })
  end

  def page_path
    if params[:page_path].present?
      params[:page_path].sub(/^\//, '')
    elsif home_page_paths.include?(request.path)
      'home'
    end
  end

  def set_page(page_path_to_use = page_path)
    @page = Page.find_by_path(page_path_to_use.to_s.downcase.sub(/^\//, ''))
  end

  # Make sure to return after calling this method, e.g. `check_for_redirect! and return` to avoid double render errors
  def check_for_redirect!
    if redirect = Redirect.published.find_by_from_path("/#{page_path}")
      redirect_to redirect.to_path, params: { page_path: redirect.to_path }, status: 301
    end
  end
end
