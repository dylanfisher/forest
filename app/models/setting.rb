class Setting < Forest::ApplicationRecord
  include Sluggable

  CACHE_KEY = 'forest_settings'
  APPLICATION_CACHE_KEY = 'forest_application_cache_key'
  DEFAULT_SETTINGS = %i(site_title description featured_image)
  VALID_VALUE_TYPES = %w(text boolean image integer string)

  after_commit :touch_associations
  after_commit :expire_cache

  scope :by_locale, -> (locale) { where(locale: locale) }

  def self.for(key, options = {})
    options.reverse_merge!(locale: I18n.locale)
    self.get(key, options).try(:value)
  end

  def self.get(key, options = {})
    options.reverse_merge!(locale: I18n.locale)

    locale = options[:locale]
    locale = locale.to_s if locale.is_a?(Symbol)

    fallback = options.fetch(:fallback, true)

    setting = self.settings.find { |s| s.slug == key.to_s && s.locale == locale }

    if setting.try(:value).blank? && fallback
      setting = self.settings.find { |s| s.slug == key.to_s && s.locale == I18n.default_locale.to_s }
    end

    setting
  end

  def self.expire_cache!
    Rails.cache.delete CACHE_KEY
  end

  def self.expire_application_cache_key!
    Rails.cache.delete APPLICATION_CACHE_KEY
  end

  def self.application_cache_key
    Rails.cache.fetch APPLICATION_CACHE_KEY do
      SecureRandom.uuid
    end
  end

  # Define setting values, value types, and descriptions in your i18n file using the following pattern:
  # en:
  #   forest:
  #     settings:
  #       banner_text:
  #         forest_setting_value: true
  #         forest_setting_value_type: boolean
  #         forest_setting_description: 'Enable a site-wide banner'
  def self.initialize_from_i18n
    I18n.backend.send(:init_translations) unless I18n.backend.initialized?

    Setting.where(locale: nil).update_all(locale: I18n.default_locale)

    I18n.available_locales.each do |locale|
      create_translations_for_locale(locale)
    end

    expire_cache!
  end

  def self.resource_description
    "Settings are where you define static values that are used throughout the site. For example the title of your website, the description, and other values."
  end

  def self.create_translations_for_locale(locale)
    settings_from_i18n = I18n.backend.send(:translations).dig(locale, :forest, :settings).presence || {}

    # Destroy any settings that are no longer in the i18n initialization or default settings array, and have not been updated.
    # This means any settings that are added directly from the database will be deleted.
    Setting.where(locale: locale).reject { |setting|
      Array(Setting::DEFAULT_SETTINGS.dup).concat(settings_from_i18n.keys).include?(setting.slug.to_sym)
    }.each { |setting|
      if setting.has_not_been_updated?
        logger.info { "[Forest][Setting] Destroying obsolete setting for #{setting.slug}" }
        setting.destroy
      end
    }

    settings_from_i18n.each do |setting|
      k = setting[0].to_s
      v = setting[1]

      if v.is_a?(Hash) && v.keys.include?(:forest_setting_value)
        v = v[:forest_setting_value]
        value_type_from_i18n = setting[1][:forest_setting_value_type] unless setting[1].try(:[], :forest_setting_value_type).nil?
        description_from_i18n = setting[1][:forest_setting_description] unless setting[1].try(:[], :forest_setting_description).nil?

        if VALID_VALUE_TYPES.none?(value_type_from_i18n)
          logger.warn { "[Forest][Setting] Warning: invalid value type '#{value_type_from_i18n}' for #{setting}. Setting value type to text." }
          value_type_from_i18n = 'text'
        end
      end

      if value_type_from_i18n == 'boolean'
        if [true, 'true'].any?(v)
          v = 1
        else
          v = 0
        end
      end

      if [k, v].all?(&:present?)
        s = Setting.get(k, locale: locale, fallback: false)

        if s.blank?
          s = Setting.new(title: k.titleize, slug: k, locale: locale)
        end

        s.value = v
        s.value_type = value_type_from_i18n unless value_type_from_i18n.nil?
        s.description = description_from_i18n unless description_from_i18n.nil?

        if s.new_record?
          logger.info { "[Forest][Setting] Creating new setting for #{k}" }
          s.save
        elsif s.has_not_been_updated?
          if s.changed?
            logger.info { "[Forest][Setting] Updating value for setting key #{k}" }
            s.update_columns(title: k.titleize, slug: k, value: v)
            s.update_column(:value_type, value_type_from_i18n) unless value_type_from_i18n.nil?
            s.update_column(:description, description_from_i18n) unless description_from_i18n.nil?
          end
        end
      else
        logger.warn { "[Forest][Setting] Warning: unable to create setting for #{setting}. Key or value is blank." }
      end
    end
  end

  def slug_as_key?
    true
  end

  def has_not_been_updated?
    updated_at == created_at
  end

  private

    def self.settings
      @memo ||= Rails.cache.fetch CACHE_KEY do
        self.all.to_a
      end
    end

    def self.reset_method_cache!
      @memo = nil
    end

    def expire_cache
      self.class.expire_cache!
    end

    # Pages may depend on settings and should be updated each time a setting is changed
    def touch_associations
      Page.update_all(updated_at: Time.now)
    end
end
