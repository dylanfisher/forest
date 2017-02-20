module Blockable
  extend ActiveSupport::Concern

  included do
    @@parent_class = self

    has_many :page_slots, -> { where(blockable_record_type: @@parent_class.name).order(:position) }, dependent: :destroy, foreign_key: 'blockable_record_id'
    has_one :blockable_record, as: :blockable_record, dependent: :destroy

    after_save :set_blockable_record

    accepts_nested_attributes_for :page_slots, allow_destroy: true
  end

  def blocks
    @blocks ||= page_slots.includes(:blockable).collect(&:blockable)
  end

  # TODO: make this searchable
  def page_block_values
    self.blockable_record.slot_cache.collect { |a| JSON.parse(a[:block_as_json]).values }
  end

  # TODO: make this more performant and/or not as weird
  def reify_page_slots!
    self.page_slots = self.blockable_record.slot_cache.collect do |data|
      if data[:blockable_id]
        block = data[:blockable_type].constantize.find(data[:blockable_id])
        block.update_attributes JSON.parse(data[:block_as_json])
        PageSlot.create page_id: self.id, blockable_id: data[:blockable_id], blockable_type: data[:blockable_type], position: data[:page_slot_position].to_i
      end
    end.reject(&:blank?)
  end

  def set_blockable_record_cache!
    set_slot_cache!
    set_block_cache!
  end

  def set_slot_cache!
    self.blockable_record.update_column :slot_cache, page_slots.includes(:blockable).collect { |page_slot|
      {
        page_slot_id: page_slot.id,
        blockable_id: page_slot.blockable_id,
        blockable_type: page_slot.blockable_type,
        page_slot_position: page_slot.position,
        block_as_json: (page_slot.block.as_json.reject { |a| page_slot_cache_blacklist_attributes.include? a }.to_json if page_slot.block)
      }
    }
  end

  def set_block_cache!
    self.blockable_record.update_column :block_cache, page_block_values
  end

  private

    def set_blockable_record
      record = self.blockable_record || self.build_blockable_record
      record.save
    end

    def page_slot_cache_blacklist_attributes
      %w(id created_at updated_at)
    end

end
