class Admin::ForestController < ApplicationController
  include Pundit

  protect_from_forgery with: :exception

  layout 'admin'

  before_action :authenticate_user!
  before_action :set_body_classes, :set_page_title
  before_action :reset_class_method_cache
  before_action :set_admin_resources

  rescue_from ActiveRecord::InvalidForeignKey, with: :foreign_key_contraint

  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  has_scope :by_status
  has_scope :by_id
  has_scope :by_title
  has_scope :by_slug
  has_scope :by_created_at
  has_scope :by_updated_at
  has_scope :by_status
  has_scope :fuzzy_search

  private

    def set_body_classes
      controller_heirarchy = self.class.name.split('::').reject(&:blank?)
      controller_heirarchy.pop if controller_heirarchy.length > 1
      controller_heirarchy = controller_heirarchy.collect { |a| "controller-class--#{a.underscore}" }.join(' ')

      classes = []
      classes << controller_heirarchy
      classes << "controller--#{controller_name}"
      classes << "action--#{action_name}"

      @body_classes = classes.join ' '
    end

    def set_page_title
      @page_title = controller_name.titleize
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
        resource_name.sub(/^admin_/, '').classify.safe_constantize
      end.reject(&:blank?)
         .reject { |r| r.class == Module }
    end

    def admin_resource_names
      @admin_resource_names ||= Rails.application.routes.routes.collect do |route|
        if route.path.spec.to_s.starts_with?('/admin') && route.requirements[:action] == 'index'
          route.name
        end
      end.reject(&:blank?)
         .uniq
         .sort
    end

    def record
      instance_variable_get("@#{controller_name.singularize}")
    end

    def foreign_key_contraint(exception)
      if record
        redirect_to edit_polymorphic_path([:admin, record]), flash: { error: ["This record can't be deleted because another record depends on it. First remove the association to the other record before deleting this one.", exception.message] }
      else
        raise
      end
    end
end
