class Setting < Forest::ApplicationRecord
  include Sluggable

  CACHE_KEY = 'forest_settings'
  APPLICATION_CACHE_KEY = 'forest_application_cache_key'
  DEFAULT_SETTINGS = %i(site_title description featured_image)
  VALID_VALUE_TYPES = %w(text plain_text boolean image integer string color)

  before_create :set_locale, if: Proc.new { |s| s.locale.blank? }
  before_save :set_title, if: Proc.new { |s| s.title.blank? }

  after_commit :touch_associations
  after_commit :expire_cache

  enum :setting_status, {
    is_not_hidden: 0,
    hidden: 1
  }

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
    Rails.cache.fetch APPLICATION_CACHE_KEY, expires_in: 4.weeks do
      SecureRandom.uuid
    end
  end

  # Define setting values, value types, and descriptions in your i18n file using the following pattern.
  # Be careful with boolean values; these are saved to the database as a string, either "0" or "1"
  # en:
  #   forest:
  #     settings:
  #       banner_text:
  #         forest_setting_value: true
  #         forest_setting_value_type: boolean
  #         forest_setting_description: 'Enable a site-wide banner'
  def self.initialize_from_i18n
    I18n.backend.send(:init_translations) unless I18n.backend.initialized?

    settings_without_locale = Setting.where(locale: nil)
    settings_without_locale.update_all(locale: I18n.default_locale) if settings_without_locale.present?

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

  # Define methods to check the value type of a setting
  # setting.boolean?, setting.text?, setting.integer?, etc.
  VALID_VALUE_TYPES.each do |vt|
    define_method :"#{vt}?" do
      value_type == vt
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
    Rails.cache.fetch CACHE_KEY, expires_in: 4.weeks do
      self.all.to_a
    end
  end

  def expire_cache
    self.class.expire_cache!
  end

  # Pages may depend on settings and should be updated each time a setting is changed
  def touch_associations
    Page.update_all(updated_at: Time.current)
  end

  def set_title
    self.title = slug.to_s.titleize
  end

  def set_locale
    self.locale = I18n.default_locale
  end
end
