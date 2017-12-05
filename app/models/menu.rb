# TODO: MenuItem class to represent each individual menu item. Could these be associated with cocoon?
class Menu < Forest::ApplicationRecord
  include Sluggable

  CACHE_KEY = 'forest_menus'

  after_save :expire_cache
  after_destroy :expire_cache

  validates :title, presence: true

  def self.for(slug)
    self.menus.select { |menu| menu.slug == slug.to_s }.first
  end

  def self.expire_cache!
    Rails.cache.delete CACHE_KEY
  end

  def self.resource_description
    "Menus are where you edit the navigation structure of your website. Menu items are composed of custom links or associations with pages."
  end

  def structure_as_json
    JSON.parse(structure.presence || '[]')
  end

  private

    def self.menus
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
