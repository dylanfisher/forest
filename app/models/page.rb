class Page < ApplicationRecord
  include Searchable
  include FilterModelScopes

  extend FriendlyId
  friendly_id :title, use: :slugged

  has_paper_trail

  serialize :page_slot_cache

  validates_presence_of :title

  before_save :set_page_slot_cache

  has_one :current_version, -> { reorder(created_at: :desc, id: :desc) }, class_name: "PaperTrail::Version", foreign_key: 'item_id'
  has_one :current_published_version, -> { reorder(created_at: :desc, id: :desc).where_object(status: 1) }, class_name: "PaperTrail::Version", foreign_key: 'item_id'
  has_many :media_items, as: :attachable
  has_many :page_slots, -> { order(:position) }
  # has_many :menus, through: :menu_pages
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

  # TODO: make this more performant and/or not as weird
  def reify_page_slots!
    self.page_slots = self.page_slot_cache.collect do |data|
      if data[:blockable_id]
        block = data[:blockable_type].constantize.find(data[:blockable_id])
        block.update_attributes JSON.parse(data[:block_as_json])
        PageSlot.create page_id: self.id, blockable_id: data[:blockable_id], blockable_type: data[:blockable_type], position: data[:page_slot_position].to_i
      end
    end.reject(&:blank?)
  end

  private

    def should_generate_new_friendly_id?
      slug.blank?
    end

    def set_page_slot_cache
      self.page_slot_cache = page_slots.collect do |page_slot|
        {
          page_slot_id: page_slot.id,
          blockable_id: page_slot.blockable_id,
          blockable_type: page_slot.blockable_type,
          page_slot_position: page_slot.position,
          block_as_json: (page_slot.block.as_json.reject { |a| page_slot_cache_blacklist_attributes.include? a }.to_json if page_slot.block)
        }
      end
    end

    def page_slot_cache_blacklist_attributes
      %w(id created_at updated_at)
    end
end
