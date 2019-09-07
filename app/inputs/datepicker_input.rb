class DatepickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    obj = input_html_options.fetch :object, object
    placeholder = options.delete(:placeholder) || 'Click to choose a date'

    datepicker_options = {}
    datepicker_options[:data] ||= {}
    datepicker_options[:data][:datepicker] = true
    datepicker_options[:data][:blank] = options.delete(:blank)

    if column.type == :datetime
      datepicker_options[:data][:timepicker] = true
      datepicker_options[:data][:timezone_utc_offset] = Time.zone.now.utc_offset
    end

    datepicker_options[:placeholder] = placeholder
    datepicker_options[:autocomplete] = 'off'

    # This needs to match the date format in datepicker_init.js
    display_date_value = obj.send(attribute_name).present? ? obj.send(attribute_name).strftime('%m/%d/%Y %I:%M %P') : nil

    input_html_options[:class] << :"datepicker-input__alt-format"
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    out = ActiveSupport::SafeBuffer.new
    out << template.text_field_tag("#{object.model_name.singular}_#{attribute_name}_preview", display_date_value, class: "form-control", **datepicker_options)
    out << @builder.hidden_field(attribute_name, merged_input_options)
  end
end
