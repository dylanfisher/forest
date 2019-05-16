module SimpleForm
  module Components
    module Remote
      def remote(wrapper_options = nil)
        @remote ||= begin
          remote_options = options[:remote].is_a?(Hash) ? options[:remote] : {}
          remote_options[:path] ||= template.polymorphic_path([:admin, reflection.klass])
          remote_options[:path] << '.json' unless remote_options[:path].match(/\.json$/i)

          input_html_options[:data] ||= {}
          input_html_options[:data][:remote_path] = remote_options[:path]
          input_html_options[:data][:remote_scope] = remote_options[:scope] || 'fuzzy_search'

          options[:wrapper_html] ||= {}
          options[:wrapper_html][:class] = "#{options[:wrapper_html][:class]} remote"

          options[:collection] = Array(object.send(reflection.name)).collect { |a|
            [a.to_label, a.id, data: { select2_response: a.to_select2_response, select2_selection: a.to_select2_selection }]
          }
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
