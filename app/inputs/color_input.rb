class ColorInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    hex_code = object.try(attribute_name).presence || options.delete(:hex_code).presence || default_hex_code
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    merged_input_options.merge!(type: :color)

    content = ActiveSupport::SafeBuffer.new
    content << content_tag(:div, input_group(hex_code, merged_input_options), class: 'input-group')
    content << content_tag(:div, default_help_text)
    content
  end

  private

    def input_group(hex_code, merged_input_options)
      "#{@builder.text_field(attribute_name, merged_input_options)}#{input_group_addon(hex_code)}".html_safe
    end

    def default_help_text
      content_tag :p, 'Click to select a color, or enter a 6 digit hex code in the box.', class: 'help-block'
    end

    def input_group_addon(hex_code)
      "<input value='#{hex_code}' type='text' maxlength='7' name='color-input-hex-tracker' class='color-input__hex-tracker input-group-addon'>".html_safe
    end

    def default_hex_code
      '#000000'
    end
end
