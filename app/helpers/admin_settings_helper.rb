module AdminSettingsHelper

  def admin_setting_value(setting)
    return setting.value if setting.value.blank?

    case setting.value_type
    when 'boolean'
      setting.value == '1' ? 'True' : 'False'
    when 'image'
      URI(setting.value).path.split('/').last
    else
      setting.value
    end
  end

end
