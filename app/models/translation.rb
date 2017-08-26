class Translation < Forest::ApplicationRecord
  CACHE_KEY = 'forest_translations'

  after_save :expire_cache
  after_destroy :expire_cache

  validates_presence_of :key
  validates_presence_of :value

  scope :by_id, -> (orderer = :asc) { order(id: orderer) }
  scope :by_key, -> (orderer = :asc) { order(key: orderer) }
  scope :by_created_at, -> (orderer = :desc) { order(created_at: orderer) }

  def self.for(key)
    self.translations.select { |setting| setting.key == key.to_s }.first
  end

  def self.expire_cache!
    Rails.cache.delete self::CACHE_KEY
  end

  # TODO: Update to support multiple locales
  def self.initialize_from_i18n
    I18n.backend.send(:init_translations) unless I18n.backend.initialized?
    translations = I18n.backend.send(:translations).dig(:en, :forest, :translations).presence || []

    translations.each do |original_translation|
      translation = original_translation.dup

      k = translation.delete(:key)
      v = translation.delete(:value)
      d = translation.delete(:description)

      if k.blank? && v.blank?
        if translation.is_a?(Hash)
          k = translation.keys.first.to_s
          v = translation[k]
        else
          k = translation[0].to_s
          v = translation[1]
        end
      end

      if [k, v].all?(&:present?)
        t = Translation.for(k)
        if t.blank?
          t = Translation.new(key: k)
        end

        t.value = v
        t.description = d

        if t.new_record?
          logger.info { "[Forest][Translation] Creating new translation for #{k}" }
          t.save
        elsif t.updated_at == t.created_at
          if t.changed?
            logger.info { "[Forest][Translation] Updating value for translation key #{k}" }
            to_update = {}
            to_update[:value] = v if t.value_changed?
            to_update[:description] = v if t.description_changed?
            t.update_columns(to_update)
          end
        end
      else
        logger.warn { "[Forest][Translation] Warning: unable to create translation for #{original_translation}. Key or value is blank." }
      end
    end

    expire_cache!
  end

  def display_name
    key
  end

  private

    def self.translations
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
