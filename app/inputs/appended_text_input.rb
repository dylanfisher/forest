class AppendedTextInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    append_text = options.delete(:append) || default_append_text
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    content_tag(:div, input_group(append_text, merged_input_options), class: "input-group")
  end

  private

  def input_group(append_text, merged_input_options)
    field_type = options.delete(:field_type) || :text_field
    "#{@builder.send(field_type, attribute_name, merged_input_options)} #{append_text_addon(append_text)}".html_safe
  end

  def append_text_addon(append_text)
    content_tag(:span, content_tag(:span, append_text, class: 'input-group-text'), class: 'input-group-append')
  end

  def default_append_text
    "%"
  end
end
