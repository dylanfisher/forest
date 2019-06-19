module TranslationHelper
  # Forest translation
  def ft(record, attribute_name, options = {})
    fallback = options.fetch(:fallback, false)
    call_method = options.fetch(:call_method, :send)

    attr_name = attribute_name.to_s
    attr_name << "_#{I18n.locale}" if I18n.locale != I18n.default_locale

    value = record.send(call_method, attr_name)

    if value.blank? && fallback
      value = record.send(call_method, attribute_name)
    end

    value
  end
end
