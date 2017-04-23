class Menu < ApplicationRecord
  CACHE_KEY = 'forest_menus'

  before_validation :generate_slug

  after_save :expire_cache
  after_destroy :expire_cache

  # TODO: validation in case a page link is no longer active, or link is wrong?
  # validate :has_valid_link
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

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

  def generate_slug
    self.slug = title.parameterize if self.slug.blank? || changed.include?('slug')
  end

  def to_param
    slug
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

    def should_generate_new_friendly_id?
      slug.blank?
    end

    def expire_cache
      self.class.expire_cache!
    end
end
