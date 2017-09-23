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

            if remote? && options[:collection].present? && reflection.present?
              options[:collection] = Array(object.send(reflection.name)).collect { |a| [a.to_label, a.id, data: { select2_response: a.to_select2_response }] }
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
