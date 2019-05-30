class DatepickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    placeholder = options.delete(:placeholder) || 'Click to choose a date'

    input_html_options[:data] ||= {}
    input_html_options[:data][:datepicker] = true
    input_html_options[:data][:blank] = options.delete(:blank)

    if column.type == :datetime
      input_html_options[:data][:timepicker] = true
      input_html_options[:data][:timezone_utc_offset] = Time.zone.now.utc_offset
    end

    input_html_options[:placeholder] = placeholder
    input_html_options[:autocomplete] = 'off'

    super
  end
end
