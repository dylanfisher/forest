module SimpleForm
  module Components
    module Markdown
      def markdown(wrapper_options = nil)
        @markdown ||= begin
          if markdown?
            input_html_options[:class] ||= []
            input_html_options[:class] << 'markdown-editor'
            input_html_options[:class] << 'markdown-editor--image-upload' if image_upload?
            input_html_options[:class] << 'markdown-editor--blockquote' if blockquote?
          end
        end
        nil
      end

      def markdown?
        options[:markdown].present?
      end

      def image_upload?
        options[:image_upload].present?
      end

      def blockquote?
        options[:blockquote].present?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::Markdown)
