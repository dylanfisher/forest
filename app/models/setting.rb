class Setting < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  CACHE_KEY = 'forest_settings'

  after_save :_expire_cache
  after_destroy :_expire_cache

  scope :by_id, -> (orderer = :asc) { order(id: orderer) }
  scope :by_title, -> (orderer = :asc) { order(title: orderer) }
  scope :by_slug, -> (orderer = :asc) { order(slug: orderer) }
  scope :by_created_at, -> (orderer = :desc) { order(created_at: orderer) }

  def self.for(title)
    self.settings.select { |setting| setting.slug.underscore == title.to_s.underscore }.first
  end

  def self.expire_cache
    Rails.cache.delete Setting::CACHE_KEY
  end

  private

    def self.settings
      Rails.cache.fetch CACHE_KEY do
        Setting.all
      end
    end

    def should_generate_new_friendly_id?
      slug.blank?
    end

    def _expire_cache
      self.class.expire_cache
    end
end
