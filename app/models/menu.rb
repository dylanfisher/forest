# TODO: MenuItem class to represent each individual menu item. Could these be associated with cocoon?
class Menu < Forest::ApplicationRecord
  include Sluggable

  CACHE_KEY = 'forest_menus'

  after_save :expire_cache
  after_destroy :expire_cache

  # TODO: validation in case a page link is no longer active, or link is wrong?
  # validate :has_valid_link
  validates :title, presence: true

  # TODO: the cached self.menus method isn't used when accessing through the join table
  # TODO: fix after page group removal
  # scope :by_page_group, -> (page_groups) { joins(:page_groups).where('page_groups.id IN (?)', page_groups.collect(&:id)) }

  def self.for(slug)
    self.menus.select { |menu| menu.slug == slug.parameterize }.first
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

  def cache_key(page, path)
    # TODO: better way to break cache when viewing a page in the menu.
    # This also needs to recursively look through the menu.
    # This is currently broken until the recursive lookup is added. And it needs a refactor.
    dependent_on_path = []

    if page
      structure_as_json.each do |item|
        dependent_on_path << [ (strip_slashes(item['url']) == strip_slashes(page.path.split('/').reject(&:blank?).last)),
          (item['page'].to_i == page.id) ].any?
      end
    end

    if dependent_on_path.any?
      "#{super}/#{path}"
    else
      super
    end
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

    def strip_slashes(string)
      string.gsub(/(^\/|\/$)/, '')
    end
end
