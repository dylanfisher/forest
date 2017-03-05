class Menu < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  CACHE_KEY = 'forest_menus'
  # PERMITTED_STRUCTURE_KEYS = %w(name children)

  after_save :_expire_cache
  after_destroy :_expire_cache

  # TODO: validation?
  # validate :has_valid_link

  def self.for(slug)
    self.menus.select { |menu| menu.slug == slug.to_s }.first
  end

  def self.expire_cache!
    Rails.cache.delete CACHE_KEY
  end

  def structure_as_json
    JSON.parse(structure.presence || '[]')
  end

  def pages
    Page.find(structure_as_json.collect { |a| a['page'] }.reject(&:blank?))
  end

  def cache_key
    "#{super}/#{Digest::MD5.hexdigest(pages.collect(&:cache_key).join)}"
  end

  private

    def self.menus
      Rails.cache.fetch CACHE_KEY do
        self.all
      end
    end

    def should_generate_new_friendly_id?
      slug.blank?
    end

    def _expire_cache
      self.class.expire_cache!
    end
end
