class Page < ApplicationRecord
  include Blockable
  include FilterModelScopes
  include Searchable
  include Statusable

  extend FriendlyId
  friendly_id :title, use: :slugged

  has_paper_trail

  # serialize :page_slot_cache

  validates_presence_of :title

  has_one :current_version, -> { reorder(created_at: :desc, id: :desc) }, class_name: "PaperTrail::Version", foreign_key: 'item_id'
  has_one :current_published_version, -> { reorder(created_at: :desc, id: :desc).where_object(status: 1) }, class_name: "PaperTrail::Version", foreign_key: 'item_id'
  has_many :media_items, as: :attachable
  # has_many :page_slots, -> { order(:position) }, dependent: :destroy
  belongs_to :featured_image, class_name: 'MediaItem'

  # accepts_nested_attributes_for :page_slots, allow_destroy: true

  scope :title_like, -> string { where('title ILIKE ?', "%#{string}%") }

  private

    def should_generate_new_friendly_id?
      slug.blank?
    end

end
