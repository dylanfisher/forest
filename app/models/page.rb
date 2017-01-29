class Page < ApplicationRecord
  include Searchable
  include FilterModelScopes

  extend FriendlyId
  friendly_id :title, use: :slugged

  has_paper_trail
  # has_paper_trail, meta: {
  #   author_id: :author_id
  # }

  validates_presence_of :title

  has_one :current_version, -> { reorder(created_at: :desc, id: :desc) }, class_name: "PaperTrail::Version", foreign_key: 'item_id'
  has_one :current_published_version, -> { reorder(created_at: :desc, id: :desc).where_object(status: 1) }, class_name: "PaperTrail::Version", foreign_key: 'item_id'
  has_many :media_items, as: :attachable
  has_many :page_slots, -> { order(:position) }
  belongs_to :featured_image, class_name: 'MediaItem'

  accepts_nested_attributes_for :page_slots, allow_destroy: true

  enum status: {
    published: 1,
    drafted: 2,
    scheduled: 3,
    pending: 4,
    hidden: 5
  }

  def blocks
    @blocks ||= page_slots.includes(:blockable).collect(&:blockable)
  end

  private

    def should_generate_new_friendly_id?
      slug.blank?
    end
end
