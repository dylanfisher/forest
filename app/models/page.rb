class Page < ApplicationRecord
  include Blockable
  include FilterModelScopes
  include Searchable
  include Statusable

  has_paper_trail

  # serialize :page_slot_cache

  before_validation :generate_slug
  after_destroy :remove_page_group_associations
  after_save :assign_page_groups!

  validates_presence_of :title
  validates_presence_of :slug
  validates_uniqueness_of :slug

  has_one :current_version, -> { reorder(created_at: :desc, id: :desc) }, class_name: 'PaperTrail::Version', foreign_key: 'item_id'
  has_one :current_published_version, -> { reorder(created_at: :desc, id: :desc).where_object(status: 1) }, class_name: 'PaperTrail::Version', foreign_key: 'item_id'

  has_many :media_items, as: :attachable
  # has_many :page_slots, -> { order(:position) }, dependent: :destroy

  belongs_to :featured_image, class_name: 'MediaItem'

  has_one :ancestor_page_group, -> { order(level: :asc) }, class_name: 'PageGroup', foreign_key: 'page_id'
  has_one :ancestor_page, -> { includes(:page_groups).order('page_groups.level ASC') }, through: :ancestor_page_group

  has_many :page_groups, -> { order(level: :asc).distinct }, class_name: 'PageGroup', dependent: :destroy
  has_many :page_group_pages, through: :page_groups, source: :parent_page, dependent: :destroy
  has_many :child_page_groups, -> { select('distinct on (page_groups.level) *') }, class_name: 'PageGroup', foreign_key: 'parent_page_id'
  has_many :ancestor_page_groups, -> { select('distinct on (page_groups.level) *') }, class_name: 'PageGroup', foreign_key: 'ancestor_page_id'
  has_many :children, -> { includes(:page_groups).distinct }, through: :child_page_groups, source: :page
  has_many :immediate_children, class_name: 'Page', foreign_key: 'parent_page_id'

  belongs_to :parent_page, class_name: 'Page'

  # accepts_nested_attributes_for :page_slots, allow_destroy: true

  scope :by_parent_page, -> (orderer = :desc) { order("pages.parent_page_id #{orderer} NULLS LAST, pages.title #{orderer}") }
  scope :title_like, -> string { where('pages.title ILIKE ?', "%#{string}%") }
  scope :parent_pages, -> { includes(:page_groups).where(page_groups: { page_id: nil }).order('pages.title ASC') } # TODO: doesn't play well with search scope
  # scope :parent_pages, -> { includes(:page_groups).order('page_groups.level ASC, pages.title ASC') }

  # def nested_page_path
  #   page_ancestors = []
  #   this_page = self
  #   while this_page.parent_page
  #     page_ancestors << this_page.parent_page
  #     this_page = this_page.parent_page
  #   end
  #   page_ancestors.reverse!
  #   page_ancestors << self
  #   page_ancestors.collect(&:slug).join('/')
  # end

  def generate_slug
    self.slug = title.parameterize unless attribute_present?('slug')
  end

  def to_param
    slug
  end

  def uniq_child_page_groups
    ancestor_page_groups.to_a.sort_by { |a| [a.page_id, a.level] }.uniq { |a| a.level }
  end

  def assign_page_groups!(assign_ancestor_page_groups = true)
    # TODO: I think when updating a parent page all page_groups that depend on that page will need to be updated as well
    self.page_groups.destroy_all # TODO: don't destroy_all before recreating associations
    ancestors = []
    page = self
    parent = page.parent_page
    index = 0

    while parent
      page_group = page.page_groups.build(page_id: page.id, parent_page_id: parent.id, title: parent.title, slug: parent.slug, level: index)
      ancestors << page_group
      page = parent
      parent = page.try :parent_page
      index += 1
    end

    # Reverse the ancestry level
    ancestors.each_with_index { |a, i| a.level = (ancestors.length - 1 - i) }
    top_ancestor = ancestors.sort { |a| a.level }.first
    ancestors.each { |a|
      a.ancestor_page_id = top_ancestor.parent_page_id
    }
    self.page_groups << ancestors

    if assign_ancestor_page_groups
      self.children.each { |a| a.assign_page_groups!(false) }
    end
  end

  def page_ancestors
    ancestors = []
    page = self
    parent = page.parent_page
    while parent
      ancestors << parent
      page = parent
      parent = page.try :parent_page
    end
    ancestors
  end

  def remove_page_group_associations
    # TODO: this isn't correct yet
    children_clone = self.children.collect(&:clone)
    self.children.where(parent_page_id: self.id).update_all(parent_page_id: nil)
    PageGroup.where(parent_page_id: self.id).destroy_all
    PageGroup.where(ancestor_page_id: self.id).update_all(ancestor_page_id: nil)
    children_clone.each(&:assign_page_groups!)
  end
end
