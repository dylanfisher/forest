class Menu < ApplicationRecord
  CACHE_KEY = 'forest_menus'
  # PERMITTED_STRUCTURE_KEYS = %w(name children)

  before_validation :generate_slug

  after_save :expire_cache
  after_destroy :expire_cache

  # TODO: validation in case a page link is no longer active, or link is wrong?
  # validate :has_valid_link
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  has_and_belongs_to_many :page_groups

  # TODO: the cached self.menus method isn't used when accessing through the join table
  scope :by_page_group, -> (page_groups) { joins(:page_groups).where('page_groups.id IN (?)', page_groups.collect(&:id)) }

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

  def cache_key
    # TODO: is this performant?
    "#{super}/#{Digest::MD5.hexdigest(pages.collect(&:cache_key).join)}"
  end

  def generate_slug
    self.slug = title.parameterize unless attribute_present?('slug') || changed.include?('slug')
  end

  def to_param
    slug
  end

  private

    def self.menus
      @menus ||= Rails.cache.fetch CACHE_KEY do
        self.all.to_a
      end
    end

    def should_generate_new_friendly_id?
      slug.blank?
    end

    def expire_cache
      self.class.expire_cache!
    end
end
