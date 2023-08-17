class PrependedTextInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    prepended_text = options.delete(:prepend) || default_prepended_text
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    content_tag(:div, input_group(prepended_text, merged_input_options), class: "input-group")
  end

  private

  def input_group(prepended_text, merged_input_options)
    field_type = options.delete(:field_type) || :text_field
    "#{prepended_text_addon(prepended_text)} #{@builder.send(field_type, attribute_name, merged_input_options)}".html_safe
  end

  def prepended_text_addon(prepended_text)
    content_tag(:span, content_tag(:span, prepended_text, class: 'input-group-text'), class: 'input-group-prepend')
  end

  def default_prepended_text
    "@"
  end
end
