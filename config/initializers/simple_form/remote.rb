module SimpleForm
  module Components
    module Remote
      def remote(wrapper_options = nil)
        @remote ||= begin
          remote_options = options[:remote].is_a?(Hash) ? options[:remote] : {}
          remote_options.reverse_merge!(path: template.polymorphic_path([:admin, reflection.klass]))

          input_html_options[:data] ||= {}
          input_html_options[:data][:remote_path] = remote_options[:path]
          input_html_options[:data][:remote_scope] = remote_options[:scope] || 'search'

          options[:wrapper_html] ||= {}
          options[:wrapper_html][:class] = "#{options[:wrapper_html][:class]} remote"

          options[:collection] = options[:collection].to_a.collect { |a| [a.to_label, a.id, data: { select2_response: a.to_select2_response }] }
        end
        nil
      end

      def remote?
        options[:remote].present?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::Remote)
