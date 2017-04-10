class Setting < ApplicationRecord
  CACHE_KEY = 'forest_settings'

  before_validation :generate_slug

  after_save :expire_cache
  after_destroy :expire_cache

  validates :slug, presence: true, uniqueness: true

  scope :by_id, -> (orderer = :asc) { order(id: orderer) }
  scope :by_title, -> (orderer = :asc) { order(title: orderer) }
  scope :by_slug, -> (orderer = :asc) { order(slug: orderer) }
  scope :by_created_at, -> (orderer = :desc) { order(created_at: orderer) }

  def self.for(slug)
    self.settings.select { |setting| setting.slug == slug.to_s.parameterize }.first
  end

  def self.expire_cache!
    Rails.cache.delete self::CACHE_KEY
  end

  def generate_slug
    self.slug = title.parameterize unless attribute_present?('slug')
  end

  def to_param
    slug
  end

  private

    def self.settings
      @settings ||= Rails.cache.fetch CACHE_KEY do
        self.all.to_a
      end
    end

    def expire_cache
      self.class.expire_cache!
    end
end
