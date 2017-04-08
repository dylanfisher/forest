class Page < ApplicationRecord
  include Blockable
  include FilterModelScopes
  include Searchable
  include Statusable

  has_paper_trail

  # serialize :page_slot_cache

  before_validation :generate_slug
  after_save :assign_page_groups!, if: :should_assign_page_groups?
  after_destroy :remove_page_group_associations!

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

  has_many :page_groups, -> { by_level }, class_name: 'PageGroup', dependent: :destroy
  has_many :child_page_groups, -> { by_level }, class_name: 'PageGroup', foreign_key: 'parent_page_id'
  has_many :ancestor_page_groups, -> { by_level }, class_name: 'PageGroup', foreign_key: 'ancestor_page_id'
  has_many :unique_page_groups, -> { by_level.distinct }, class_name: 'PageGroup', dependent: :destroy
  has_many :unique_child_page_groups, -> { select('distinct on (page_groups.level, page_groups.page_id, page_groups.parent_page_id) *').by_level }, class_name: 'PageGroup', foreign_key: 'parent_page_id'
  has_many :unique_ancestor_page_groups, -> { select('distinct on (page_groups.level, page_groups.page_id, page_groups.parent_page_id) *').by_level }, class_name: 'PageGroup', foreign_key: 'ancestor_page_id'
  has_many :page_group_pages, through: :page_groups, source: :parent_page, dependent: :destroy
  has_many :children, -> { includes(:page_groups) }, through: :ancestor_page_groups, source: :page
  has_many :immediate_children, class_name: 'Page', foreign_key: 'parent_page_id'

  belongs_to :parent_page, class_name: 'Page'

  # accepts_nested_attributes_for :page_slots, allow_destroy: true

  scope :by_parent_page, -> (orderer = :desc) { order("pages.parent_page_id #{orderer} NULLS #{orderer == :desc ? 'LAST' : 'FIRST'}, pages.title #{orderer}, pages.id ASC") }
  scope :by_title, -> (orderer = :asc) { order(title: orderer) }
  scope :title_like, -> string { where('pages.title ILIKE ?', "%#{string}%") }
  scope :parent_pages, -> { where(parent_page_id: nil).order(:title, :id) } # TODO: doesn't play well with search scope
  # scope :parent_pages, -> { includes(:page_groups).where(page_groups: { page_id: nil }).order('pages.title ASC') } # TODO: doesn't play well with search scope
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
    # TODO: generate unique slug representing the page group hiearchy
    self.slug = title.parameterize unless attribute_present?('slug')
  end

  def to_param
    slug
  end

  # def uniq_child_page_groups
  #   ancestor_page_groups.to_a.sort_by { |a| [a.page_id, a.level] }.uniq { |a| a.level }
  # end

  def assign_page_groups!
    # TODO: DRY this up
    parent_or_self = self.parent_page || self

    # TODO: more efficient way than destroying all?
    parent_or_self.ancestor_page_groups.destroy_all
    self.page_groups.destroy_all

    # Ancestors
    ancestors = []
    page = self
    parent = page.parent_page
    index = 0

    while parent.present?
      page_group = page.page_groups.build(page_id: page.id, parent_page_id: parent.id, title: parent.title, slug: parent.slug, level: index)
      ancestors << page_group
      page = parent
      parent = page.try :parent_page
      index += 1
    end

    # Descendents
    descendents = []
    children = parent_or_self.immediate_children
    index = 0

    while children.present?
      children.each do |page|
        parent = page.parent_page
        page_group = page.page_groups.build(page_id: page.id, parent_page_id: parent.id, title: parent.title, slug: parent.slug, level: index)
        descendents << page_group
      end
      children = children.collect(&:immediate_children).reject(&:blank?).flatten
      index += 1
    end

    # Descendents
    final_descendents = []
    top_ancestor = ancestors.last&.parent_page || descendents.first&.parent_page

    if top_ancestor.present?
      children = top_ancestor.immediate_children
      index = 0

      while children.present?
        children.each do |page|
          parent = page.parent_page
          page_group = page.page_groups.build(page_id: page.id, parent_page_id: parent.id, ancestor_page_id: top_ancestor.id, title: parent.title, slug: parent.slug, level: index)
          final_descendents << page_group
        end
        children = children.collect(&:immediate_children).reject(&:blank?).flatten
        index += 1
      end
    end

    page_ids_to_touch = []
    page_ids_to_touch << top_ancestor.id if top_ancestor.present?
    page_ids_to_touch.concat final_descendents.collect(&:parent_page_id)
    page_ids_to_touch.uniq!

    Page.where(id: page_ids_to_touch).update_all(updated_at: DateTime.now)

    self.page_groups << final_descendents
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

  def remove_page_group_associations!
    Page.where(id: find_children_recursively.collect(&:id)).update_all(parent_page_id: nil, updated_at: DateTime.now)
    assign_page_groups! if self.parent_page.present?
  end

  def find_children_recursively
    descendents = []
    children = self.immediate_children

    while children.present?
      descendents.concat children
      children = children.collect(&:immediate_children).reject(&:blank?).flatten
    end

    descendents
  end

  private

    def valid_for_page_group?
      self.parent_page.present? || self.children.any?
    end

    def should_assign_page_groups?
      valid_attributes_for_change = %w(parent_page_id title slug)
      (self.changed & valid_attributes_for_change).any? && valid_for_page_group?
    end
end
