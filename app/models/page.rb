class Page < ApplicationRecord
  include Blockable
  include FilterModelScopes
  include Searchable
  include Statusable

  has_paper_trail

  # serialize :page_slot_cache

  before_validation :generate_slug

  validates_presence_of :title
  validates_presence_of :slug
  validates_uniqueness_of :slug

  has_one :current_version, -> { reorder(created_at: :desc, id: :desc) }, class_name: 'PaperTrail::Version', foreign_key: 'item_id'
  has_one :current_published_version, -> { reorder(created_at: :desc, id: :desc).where_object(status: 1) }, class_name: 'PaperTrail::Version', foreign_key: 'item_id'

  has_many :media_items, as: :attachable
  # has_many :page_slots, -> { order(:position) }, dependent: :destroy

  belongs_to :featured_image, class_name: 'MediaItem'

  has_many :pages, class_name: 'Page', foreign_key: 'parent_page_id'
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
end
