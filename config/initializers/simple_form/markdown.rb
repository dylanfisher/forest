module SimpleForm
  module Components
    module Markdown
      def markdown(wrapper_options = nil)
        @markdown ||= begin
          if markdown?
            input_html_options[:class] ||= []
            input_html_options[:class] << 'markdown-editor'
          end
        end
        nil
      end

      def markdown?
        options[:markdown].present?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::Markdown)
