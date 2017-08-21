class Setting < Forest::ApplicationRecord
  include Sluggable

  CACHE_KEY = 'forest_settings'

  after_save :expire_cache
  after_destroy :expire_cache

  scope :by_id, -> (orderer = :asc) { order(id: orderer) }
  scope :by_title, -> (orderer = :asc) { order(title: orderer) }
  scope :by_created_at, -> (orderer = :desc) { order(created_at: orderer) }

  def self.for(slug)
    self.settings.select { |setting| setting.slug == slug.to_s.parameterize }.first
  end

  def self.expire_cache!
    Rails.cache.delete self::CACHE_KEY
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
