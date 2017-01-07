module Forest
  module FormHelper
    def dropdown_select_form(options = {})
       url            = options.fetch :url
       id             = options.fetch :id
       select_options = options.fetch :select_options
       title          = options.fetch :title, nil
       css_class      = options.fetch :css_class, nil

       form_tag url, method: :get, enforce_utf8: false, class: "select-tag-form #{css_class}" do
         # concat params_as_hidden_fields id
         concat select_tag_dropdown id: id,
               select_options: select_options,
               title: title,
               selected: params[id]
       end
     end

      private

        def select_tag_dropdown(options = {})
          id                 = options.fetch :id
          select_options     = options.fetch :select_options
          title              = options.fetch :title, nil
          selected           = options.fetch :selected, nil
          options_for_select = title ? select_options.unshift([title, '']) : select_options

          select_tag id,
            options_for_select(options_for_select, selected),
              id: id,
              class: 'select-tag--default',
              data: {
              form_title: title
            }
        end

        def params_as_hidden_fields(additional_params_to_ignore)
          params_to_ignore = :controller, :action, :locale, :utf8
          params_to_process = params_to_ignore.reject { |param| param == additional_params_to_ignore.to_s }
          params_to_process.collect do |param|
            hidden_field_tag param
          end.join.html_safe
        end
  end
end
