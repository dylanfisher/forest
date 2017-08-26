class ForestController < ApplicationController
  protect_from_forgery with: :exception

  before_action :set_body_classes
  before_action :set_page_title
  before_action :reset_class_method_cache

  private

    def set_body_classes
      controller_heirarchy = self.class.name.split('::').reject(&:blank?)
      controller_heirarchy.pop
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
      Translation.reset_method_cache!
    end
end
