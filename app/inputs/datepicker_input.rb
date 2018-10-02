class DatepickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    placeholder = options.delete(:placeholder) || 'Click to choose a date'

    input_html_options[:data] ||= {}
    input_html_options[:data][:datepicker] = true
    input_html_options[:placeholder] = placeholder

    super
  end
end
