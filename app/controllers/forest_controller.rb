class ForestController < ApplicationController
  include Pundit

  protect_from_forgery with: :exception
  before_action :set_body_classes, :set_page_title
  before_action :authentication_check

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
      unless controller_name == 'public' || action_name == 'show' || action_name == 'show_index'
        authenticate_user!
      end
    end

    # def user_not_authorized
    #   if Rails.env.production?
    #     redirect_to(root_path)
    #   else
    #     raise Pundit::NotAuthorizedError
    #   end
    # end
end
