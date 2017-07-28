class ForestController < ApplicationController
  include Pundit

  protect_from_forgery with: :exception
  before_action :set_body_classes, :set_page_title
  before_action :authentication_check
  before_action :reset_class_method_cache
  before_action :set_admin_resources, if: :current_user

  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :public?
  helper_method :admin?

  private

    def set_body_classes
      classes = []
      classes << "controller--#{controller_name}"
      classes << "action--#{action_name}"
      @body_classes = classes.join ' '
    end

    def set_page_title
      @page_title = controller_name.titleize
    end

    def authentication_check
      # TODO: cleaner authentication_check ?
      unless public?
        authenticate_user!
      end
    end

    # TODO: rename this public_area?
    def public?
      # TODO: Do we need a more specific public/admin check?
      (controller_name == 'public' ||
        action_name == 'show' ||
        action_name == 'show_index') &&
        request.path.match(/^\/admin\//).nil?
    end

    # TODO: rename this admin_area?
    def admin?
      !public?
    end

    def reset_class_method_cache
      Menu.reset_method_cache!
      Setting.reset_method_cache!
    end

    # def user_not_authorized
    #   if Rails.env.production?
    #     redirect_to root_path
    #   else
    #     raise Pundit::NotAuthorizedError
    #   end
    # end

    def set_admin_resources
      @admin_resources ||= admin_resource_names.collect do |resource_name|
        resource_name.classify.safe_constantize
      end.reject(&:blank?)
    end

    def admin_resource_names
      Rails.application.routes.routes.collect do |route|
        if route.path.spec.to_s.starts_with?('/admin') && route.requirements[:action] == 'index'
          route.name
        end
      end.reject(&:blank?).uniq
    end
end
