class Page < ApplicationRecord
  include Blockable
  include FilterModelScopes
  include Searchable
  include Statusable

  has_paper_trail

  # serialize :page_slot_cache

  before_validation :generate_slug
  after_save :assign_page_groups!

  validates_presence_of :title
  validates_presence_of :slug
  validates_uniqueness_of :slug

  has_one :current_version, -> { reorder(created_at: :desc, id: :desc) }, class_name: 'PaperTrail::Version', foreign_key: 'item_id'
  has_one :current_published_version, -> { reorder(created_at: :desc, id: :desc).where_object(status: 1) }, class_name: 'PaperTrail::Version', foreign_key: 'item_id'

  has_many :media_items, as: :attachable
  # has_many :page_slots, -> { order(:position) }, dependent: :destroy

  belongs_to :featured_image, class_name: 'MediaItem'

  has_many :pages, class_name: 'Page', foreign_key: 'parent_page_id'
  has_many :page_groups, -> { order(level: :asc).distinct }, class_name: 'PageGroup', dependent: :destroy
  has_many :page_group_pages, through: :page_groups, source: :parent_page

  belongs_to :parent_page, class_name: 'Page'

  # accepts_nested_attributes_for :page_slots, allow_destroy: true

  scope :by_parent_page, -> (orderer = :desc) { order("parent_page_id #{orderer} NULLS LAST, title #{orderer}") }
  scope :title_like, -> string { where('title ILIKE ?', "%#{string}%") }

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

  def assign_page_groups!
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
    self.page_groups << ancestors
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
end
