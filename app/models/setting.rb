class Setting < Forest::ApplicationRecord
  include Sluggable

  CACHE_KEY = 'forest_settings'

  after_save :expire_cache
  after_destroy :expire_cache

  def self.for(key)
    self.get(key).try(:value)
  end

  def self.get(key)
    self.settings.select { |setting| setting.slug == key.to_s }.first
  end

  def self.expire_cache!
    Rails.cache.delete self::CACHE_KEY
  end

  # TODO: Update this to support description and boolean values
  def self.initialize_from_i18n
    I18n.backend.send(:init_translations) unless I18n.backend.initialized?
    settings = I18n.backend.send(:translations).dig(:en, :forest, :settings).presence || []

    settings.each do |setting|
      k = setting[0].to_s
      v = setting[1]

      if [k, v].all?(&:present?)
        s = Setting.get(k)
        if s.blank?
          s = Setting.new(title: k.titleize, slug: k)
        end

        s.value = v

        if s.new_record?
          logger.info { "[Forest][Setting] Creating new setting for #{k}" }
          s.save
        elsif s.updated_at == s.created_at
          if s.changed?
            logger.info { "[Forest][Setting] Updating value for setting key #{k}" }
            s.update_columns(title: k.titleize, slug: k, value: v)
          end
        end
      else
        logger.warn { "[Forest][Setting] Warning: unable to create setting for #{setting}. Key or value is blank." }
      end
    end

    expire_cache!
  end

  def slug_as_key?
    true
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
end
