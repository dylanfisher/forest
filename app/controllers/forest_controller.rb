require 'webpacker/helper'

class ForestController < ApplicationController
  include Pundit

  protect_from_forgery with: :exception, prepend: true
  skip_before_action :verify_authenticity_token, if: -> { controller_name == 'sessions' && action_name == 'create' }

  layout :layout_by_resource

  before_action :set_html_classes
  before_action :reset_class_method_cache

  helper_method :current_webpacker_instance

  def after_sign_in_path_for(resource)
    main_app.admin_path
  end

  private

    def layout_by_resource
      devise_controller? ? 'devise' : 'application'
    end

    def current_webpacker_instance
      if devise_controller?
        Forest.webpacker
      else
        Webpacker.instance
      end
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

    def reset_class_method_cache
      Menu.reset_method_cache!
      Setting.reset_method_cache!
    end

    def home_page_paths
      ['/', '/home'].concat(I18n.available_locales.collect { |l| "/#{l}" })
    end

    def page_path
      if params[:page_path].present?
        params[:page_path]
      elsif home_page_paths.include?(request.path)
        'home'
      end
    end

    def set_page
      @page = Page.find_by_path(page_path)
    end
end
