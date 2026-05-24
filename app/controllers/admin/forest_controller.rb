class Admin::ForestController < ApplicationController
  include Pagy::Backend
  include Pundit::Authorization

  protect_from_forgery with: :exception, prepend: true

  layout 'admin'

  before_action :authenticate_user!
  before_action :set_html_classes, :set_page_title
  before_action :set_admin_resources

  after_action :verify_authorized, unless: :devise_controller?

  rescue_from ActiveRecord::InvalidForeignKey, with: :foreign_key_constraint
  rescue_from ActiveRecord::RecordNotUnique, with: :record_not_unique

  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :localized_input
  helper_method :recognize_path

  has_scope :by_status
  has_scope :by_id
  has_scope :by_title
  has_scope :by_slug
  has_scope :by_created_at
  has_scope :by_updated_at
  has_scope :by_status
  has_scope :fuzzy_search

  private

  def set_html_classes
    controller_heirarchy = self.class.name.split('::').reject(&:blank?)
    controller_heirarchy.pop if controller_heirarchy.length > 1
    controller_heirarchy = controller_heirarchy.collect { |a| "controller-class--#{a.underscore}" }.join(' ')

    classes = []
    classes << controller_heirarchy
    classes << "controller--#{controller_name}"
    classes << "action--#{action_name}"

    @html_classes = classes.join ' '
  end

  def set_page_title
    @page_title = controller_name.titleize
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
       .select { |r| policy(r).dashboard? }
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

  def foreign_key_constraint(exception)
    if record
      statusable_message = record.try(:statusable?) ? ' Alternatively, you may want to set this record\'s status to hidden instead.' : ''
      error_messages = ["This record can't be deleted because another record depends on it. First remove the association to the other record before deleting this one.#{statusable_message}", "<code>#{exception.message}</code>"]
      if record.new_record?
        error_messages.each { |e| record.errors.add(:base, e) }
        return render :new
      else
        return redirect_to edit_polymorphic_path([*forest_controller_namespace, record]), flash: { error: error_messages }
      end
    else
      raise
    end
  end

  def record_not_unique(exception)
    if record && record.try(:sluggable?)
      error_messages = ["A record with this slug already exists. Please create a unique slug.", "<code>#{exception.message}</code>"]
      if record.new_record?
        error_messages.each { |e| record.errors.add(:base, e) }
        return render :new
      else
        return redirect_to edit_polymorphic_path([*forest_controller_namespace, record]), flash: { error: error_messages }
      end
    else
      raise
    end
  end

  def localized_input(form, attribute, locale, options = {})
    locale = locale.to_s
    label = options.fetch(:label, attribute.to_s.humanize).sub(/ (#{locale})$/i, '')
    options.merge!(label: "#{label} (#{locale.to_s.upcase})") unless I18n.available_locales.length < 2

    locale_suffix = locale == I18n.default_locale.to_s ? '' : "_#{locale}"
    localized_attribute = "#{attribute}#{locale_suffix}"

    if form.object.respond_to? localized_attribute
      form.input localized_attribute, options
    end
  end

  def recognize_path(path, options = {})
    Rails.application.routes.recognize_path(path, options)
  rescue ActionController::RoutingError
  end

  def forest_controller_namespace
    controller_namespace_parts = self.class.name.split('::').reject(&:blank?)
    controller_namespace_parts = controller_namespace_parts[0..(controller_namespace_parts.size - 2)]
    controller_namespace_parts = controller_namespace_parts.collect { |x| x.underscore.to_sym }
    controller_namespace_parts
  end
end
