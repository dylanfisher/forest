class Page < Forest::ApplicationRecord
  include Blockable
  include FilterModelScopes
  include Searchable
  include Statusable
  # include Versionable

  before_validation :generate_slug
  # before_validation :assign_page_heirarchy! if :hierarchy_changed?
  before_validation :generate_path if :hierarchy_changed?

  after_save :touch_associated_pages if :hierarchy_changed?
  after_save :expire_menu_cache

  after_destroy :remove_page_hierarchy!

  validates_presence_of :title
  validates_presence_of :slug
  validates_presence_of :path
  validates_uniqueness_of :slug, scope: :parent_page_id
  validates_uniqueness_of :path
  validate :parent_page_is_not_self

  has_many :media_items, as: :attachable
  has_many :immediate_children, -> { by_title }, class_name: 'Page', foreign_key: 'parent_page_id'

  belongs_to :featured_image, class_name: 'MediaItem'
  belongs_to :parent_page, class_name: 'Page'

  scope :by_parent_page, -> (orderer = :desc) { order("pages.parent_page_id #{orderer} NULLS #{orderer == :desc ? 'LAST' : 'FIRST'}, pages.title #{orderer}, pages.id ASC") }
  scope :by_title, -> (orderer = :asc) { order(title: orderer, id: :desc) }
  scope :title_like, -> (string) { where('pages.title ILIKE ?', "%#{string}%") }
  scope :parent_pages, -> { where(parent_page_id: nil).order(:title, :id) }
  scope :non_parent_pages, -> { where('pages.parent_page_id IS NOT NULL').order(:title, :id) }

  def generate_slug
    self.slug = title.parameterize if self.slug.blank? || changed.include?('slug')
  end

  def to_param
    path
  end

  def page_ancestors
    # TODO: these recursive function aren't performant and should be cached in the view
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

  def page_descendents
    # TODO: these recursive function aren't performant and should be cached in the view
    descendents = []
    children = self.immediate_children

    while children.present?
      descendents.concat children
      children = children.collect(&:immediate_children).reject(&:blank?).flatten
    end

    descendents
  end

  def all_associated_pages
    # TODO: these recursive function aren't performant and should be cached in the view
    page_ancestors.concat(page_ancestors.each.collect(&:page_descendents)).flatten
  end

  # def assign_page_heirarchy!
  #   Page.where(id: [self.id, *self.page_descendents.collect(&:id)]).update_all(updated_at: DateTime.now)
  # end

  def remove_page_hierarchy!
    pages_to_touch = Page.where(id: [self.id, *self.page_descendents.collect(&:id)])
    self.immediate_children.update_all(parent_page_id: nil)
    pages_to_touch.update_all(updated_at: DateTime.now)
    # generate_path
  end

  def select2_format
    ((page_ancestors.length + 1).times.collect{}.join('&mdash; ') + title).as_json
  end

  private

    def valid_for_page_group?
      self.parent_page.present? || self.immediate_children.any?
    end

    def hierarchy_changed?
      valid_attributes_for_change = %w(parent_page_id slug)
      (self.changed & valid_attributes_for_change).any?
    end

    def generate_path
      if page_ancestors.any?
        generated_path = "#{page_ancestors.collect(&:slug).join('/')}/#{self.slug}"
      else
        generated_path = self.slug
      end
      self.path = generated_path
    end

    def touch_associated_pages
      Page.where(id: all_associated_pages.collect(&:id)).update_all(updated_at: DateTime.now)
    end

    def parent_page_is_not_self
      if parent_page == self
        errors.add :parent_page, "a parent page can't be assigned to itself."
      end
    end

    def expire_menu_cache
      Menu.expire_cache!
    end
end
