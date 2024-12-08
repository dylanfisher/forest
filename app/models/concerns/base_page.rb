module BasePage
  extend ActiveSupport::Concern

  included do
    include Blockable
    include Statusable
    # TODO: refactor to use Pathable concern

    before_validation :generate_slug
    before_validation :generate_path, if: :hierarchy_changed?

    after_save :generate_descendent_paths, if: :hierarchy_changed?
    after_save :expire_menu_cache

    after_destroy :remove_page_hierarchy!

    validates_presence_of :title
    validates_presence_of :slug
    validates_presence_of :path
    validates_uniqueness_of :slug, scope: :parent_page_id
    validates_uniqueness_of :path
    validate :parent_page_is_not_self_or_ancestor

    has_many :immediate_children, -> { by_title }, class_name: 'Page', foreign_key: 'parent_page_id'

    belongs_to :featured_image, class_name: 'MediaItem', optional: true
    belongs_to :parent_page, class_name: 'Page', optional: true

    scope :by_parent_page, -> (orderer = :desc) { order("pages.parent_page_id #{orderer} NULLS #{orderer == :desc ? 'LAST' : 'FIRST'}, pages.title #{orderer}, pages.id ASC") }
    scope :title_like, -> (string) { where('pages.title ILIKE ?', "%#{string}%") }
    scope :parent_pages, -> { where(parent_page_id: nil).order(:title, :id) }
    scope :non_parent_pages, -> { where('pages.parent_page_id IS NOT NULL').order(:title, :id) }
  end

  class_methods do
    def resource_description
      "Pages offer a flexible and modular way to present information."
    end
  end

  def to_friendly_param
    path
  end

  def generate_slug
    self.slug = title.parameterize if self.slug.blank?
  end

  def generate_path
    if page_ancestors.any?
      generated_path = "#{page_ancestors.reverse.collect(&:slug).join('/')}/#{self.slug}"
    else
      generated_path = self.slug
    end
    self.path = generated_path
  end

  def generate_descendent_paths
    page_descendents.each do |page_descendent|
      page_descendent.generate_path
      page_descendent.save
    end
  end

  def page_ancestors
    # Note: these recursive function aren't performant and should be cached in the view
    @_page_ancestors ||= begin
      ancestors ||= []
      page = self
      parent = page.parent_page unless page.parent_page == page
      while parent
        ancestors << parent
        page = parent
        parent = page.try :parent_page
      end
      ancestors
    end
  end

  def page_descendents
    # Note: these recursive function aren't performant and should be cached in the view
    @_page_descendents ||= begin
      descendents = []
      children = self.immediate_children

      while children.present?
        descendents.concat children
        children = children.collect(&:immediate_children).reject(&:blank?).flatten
      end

      descendents
    end
  end

  def page_root
    @_page_root ||= page_ancestors.find { |p| p.parent_page_id.nil? }
  end

  def descendent_of?(page_or_page_slug)
    if page_or_page_slug.is_a?(Page)
      page_ancestors.any? { |p| p == page_or_page_slug }
    else
      page_ancestors.any? { |p| p.slug == page_or_page_slug }
    end
  end

  def all_associated_pages
    @_all_associated_pages ||= page_ancestors.concat(page_ancestors.each.collect(&:page_descendents)).flatten
  end

  def remove_page_hierarchy!
    self.immediate_children.update(parent_page_id: nil)
  end

  # Returns a collection of media items that represent the basic images on the page. Override this
  # method in your host app if your pages often contain images stored under other attribute names.
  def typical_media_items
    media_item_ids = []
    media_item_ids.push(featured_image_id) if featured_image_id.present?

    blocks.each do |b|
      media_item_ids.push(b.media_item_id) if b.try(:media_item_id).present?
      media_item_ids.concat(b.media_item_ids) if b.try(:media_item_ids).present?
    end

    if media_item_ids.present?
      MediaItem.images.where(id: media_item_ids.uniq)
    else
      MediaItem.none
    end
  end

  def to_select2_response
    if respond_to?(:media_item) && media_item.try(:attachment_url, :thumb).present?
      img_tag = "<img src='#{media_item.attachment_url(:thumb)}' style='height: 21px; margin-right: 5px;'> "
    end
    status = ApplicationController.helpers.status_indicator(self, class: 'select2-response__status') if self.try(:statusable?)
    if page_ancestors.present?
      select2_parent_page_label = "<span style='color: #aaa; font-size: smaller; margin-right: 5px;'>#{page_ancestors.reverse.collect(&:title).join(' > ')}</span>"
    end
    "#{img_tag}<span class='select2-response__id' data-id='#{id}' style='margin-right: 5px;'>#{status}#{id}</span> #{select2_parent_page_label}#{to_label}"
  end

  private

  def current_or_previous_changes
    self.changed.presence || self.previous_changes.keys
  end

  def hierarchy_changed?
    (current_or_previous_changes & %w(parent_page_id slug)).any?
  end

  def parent_page_is_not_self_or_ancestor
    if parent_page == self
      errors.add :parent_page, "a parent page can't be assigned to itself."
    elsif page_ancestors.include?(self)
      errors.add :parent_page, "a parent page can't be assigned to an ancestor of itself."
    end
  end

  def expire_menu_cache
    Menu.expire_cache!
  end
end
