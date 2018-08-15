class Menu < Forest::ApplicationRecord
  include Sluggable

  CACHE_KEY = 'forest_menus'

  after_commit :expire_cache

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

  def nokogiri
    @nokogiri ||= begin
      fragment = Nokogiri::HTML.fragment('<ul></ul>')
      structure_as_json.each do |menu_item|
        create_nokogiri_children(menu_item, fragment.at_css('ul'))
      end
      fragment
    end
  end

  def render
    nokogiri.to_html.html_safe
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

    def create_nokogiri_children(menu_item, node)
      node.add_child("<li><a href='#{menu_item['url']}'>#{menu_item['name']}</a></li>")
      if menu_item['children'].present?
        node.css('> li').last.add_child('<ul></ul>')
        menu_item['children'].each do |menu_item_child|
          create_nokogiri_children(menu_item_child, node.css('> li').last.css('> ul').last)
        end
      end
    end
end
