class DatepickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    input_html_options[:data] ||= {}
    input_html_options[:data][:datepicker] = true

    super
  end
end
