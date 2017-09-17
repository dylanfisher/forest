module SimpleForm
  module Components
    module Sortable
      def sortable(wrapper_options = nil)
        @sortable ||= begin
          if sortable?
            input_html_options[:data] ||= {}
            input_html_options[:data][:sortable] = true

            options[:wrapper_html] ||= {}
            options[:wrapper_html][:class] = "#{options[:wrapper_html][:class]} sortable"

            if remote?
              association = options[:collection].model_name.collection
              klass = options[:collection].klass
              options[:collection] = self.object.send(association)
            end
          end
        end
        nil
      end

      def sortable?
        options[:sortable].present? && options.dig(:input_html, :multiple).present?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::Sortable)
