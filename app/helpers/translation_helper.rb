module TranslationHelper
  # Forest translation
  def ft(record, attribute_name, options = {})
    fallback = options.fetch(:fallback, false)

    attr_name = attribute_name.to_s
    attr_name << "_#{I18n.locale}" if I18n.locale != I18n.default_locale

    value = record.send(attr_name)

    if value.blank? && fallback
      value = record.send(attribute_name)
    end

    value
  end
end
