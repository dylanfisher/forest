class TimepickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    obj = input_html_options.fetch :object, object
    placeholder = options.delete(:placeholder) || 'Click to choose a time'

    time_format = ' %I:%M %P'

    # This should match the time format in timepicker_init.js
    display_date_value = obj.send(attribute_name).present? ? obj.send(attribute_name).strftime(time_format) : nil

    input_html_options[:value] = display_date_value

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    out = ActiveSupport::SafeBuffer.new
    out << @builder.text_field(attribute_name, merged_input_options)
    out
  end
end
