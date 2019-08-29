class ForestController < ApplicationController
  include Pundit

  protect_from_forgery with: :exception, prepend: true
  skip_before_action :verify_authenticity_token, if: -> { controller_name == 'sessions' && action_name == 'create' }

  layout :layout_by_resource

  before_action :set_body_classes
  before_action :reset_class_method_cache

  def after_sign_in_path_for(resource)
    main_app.admin_path
  end

  private

    def layout_by_resource
      devise_controller? ? 'devise' : 'application'
    end

    def set_body_classes
      controller_heirarchy = self.class.name.split('::').reject(&:blank?)
      controller_heirarchy.pop
      controller_heirarchy = controller_heirarchy.collect { |a| "controller-class--#{a.underscore}" }.join(' ')

      @body_classes ||= []
      @body_classes << controller_heirarchy
      @body_classes << "controller--#{controller_name}"
      @body_classes << "action--#{action_name}"
      @body_classes << 'current-user--admin' if current_user&.admin?
    end

    def reset_class_method_cache
      Menu.reset_method_cache!
      Setting.reset_method_cache!
      Translation.reset_method_cache!
    end

    def page_path
      if params[:page_path].present?
        params[:page_path]
      elsif ['/', '/home'].include?(request.path)
        'home'
      end
    end

    def set_page
      @page = Page.find_by_path(page_path)
    end
end
