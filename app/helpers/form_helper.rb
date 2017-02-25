module FormHelper

  def dropdown_select_form(options = {})
    url                    = options.fetch :url
    id                     = options.fetch :id
    select_options         = options.fetch :select_options
    title                  = options.fetch :title, nil
    css_class              = options.fetch :css_class, nil
    remote_parent          = options.fetch :remote_parent, nil
    remote_target          = options.fetch :remote_target, nil
    remote_response_target = options.fetch :remote_response_target, nil

    if remote_parent && remote_target && remote_response_target
      remote = true
    end

    if remote
      form_tag_base_css_class = 'select-tag-remote-form'
    else
      form_tag_base_css_class = 'select-tag-form'
    end

    form_tag url, method: :get, enforce_utf8: false, class: "#{form_tag_base_css_class} #{css_class}" do
      # concat params_as_hidden_fields id
      concat select_tag_dropdown id: id,
        select_options: select_options,
        title: title,
        selected: params[id],
        remote_parent: remote_parent,
        remote_target: remote_target,
        remote_response_target: remote_response_target
    end
  end

  private

    def select_tag_dropdown(options = {})
      id                     = options.fetch :id
      select_options         = options.fetch :select_options
      title                  = options.fetch :title, nil
      selected               = options.fetch :selected, nil
      remote_parent          = options.fetch :remote_parent, nil
      remote_target          = options.fetch :remote_target, nil
      remote_response_target = options.fetch :remote_response_target, nil
      remote_attributes      = {}
      options_for_select     = title ? select_options.unshift([title, '']) : select_options

      if remote_parent && remote_target && remote_response_target
        remote = true
      end

      if remote
        css_class = 'select-tag--remote'
        remote_attributes = {
          remote_parent: remote_parent,
          remote_target: remote_target,
          remote_response_target: remote_response_target
        }
      else
        css_class = 'select-tag--default'
      end

      select_tag id,
        options_for_select(options_for_select, selected),
          id: id,
          class: css_class,
          style: 'width: 100%',
          data: {
            form_title: title,
            **remote_attributes
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
