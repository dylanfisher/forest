class ForestController < ApplicationController
  include Pundit

  protect_from_forgery with: :exception
  before_action :set_body_classes, :set_page_title
  before_action :authentication_check
  before_filter :reset_class_method_cache

  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

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

    # def define_global_instance_variables
    #   if public?
    #     @public = true
    #   elsif admin?
    #     @admin = true
    #   end
    # end

    def public?
      # TODO: Do we need a more specific public/admin check?
      controller_name == 'public' || action_name == 'show' || action_name == 'show_index'
    end

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
end
