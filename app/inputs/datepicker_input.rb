class DatepickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    obj = input_html_options.fetch :object, object
    placeholder = options.delete(:placeholder) || 'Click to choose a date'

    datepicker_options = {}
    datepicker_options[:data] ||= {}
    datepicker_options[:data][:datepicker] = true
    datepicker_options[:data][:blank] = options.delete(:blank)

    date_format = '%m/%d/%Y'

    if column.type == :datetime
      datepicker_options[:data][:timepicker] = options.fetch(:timepicker, true)
      datepicker_options[:data][:timezone_utc_offset] = Time.zone.now.utc_offset

      date_format << ' %I:%M %P'
    end

    datepicker_options[:placeholder] = placeholder
    datepicker_options[:autocomplete] = 'off'
    datepicker_options[:disabled] = options[:disabled]
    datepicker_options[:readonly] = options[:readonly]

    # This needs to match the date format in datepicker_init.js
    display_date_value = obj.send(attribute_name).present? ? obj.send(attribute_name).strftime(date_format) : nil

    input_html_options[:class] << :"datepicker-input__alt-format"
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    out = ActiveSupport::SafeBuffer.new
    out << template.text_field_tag("#{object.model_name.singular}_#{attribute_name}_#{object.try(:id)}_preview", display_date_value, class: "form-control", **datepicker_options)
    out << @builder.hidden_field(attribute_name, merged_input_options)
    out
  end
end
