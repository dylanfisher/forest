module Forest
  module AdminSettingsHelper

    def admin_setting_value(setting)
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
end
