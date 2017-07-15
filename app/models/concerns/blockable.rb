module Blockable
  extend ActiveSupport::Concern

  included do
    parent_class = self

    has_many :block_slots, -> { where(block_record_type: parent_class.name).order(:position) }, dependent: :destroy, foreign_key: 'block_record_id'
    has_one :block_record, as: :block_record, dependent: :destroy

    accepts_nested_attributes_for :block_slots, allow_destroy: true

    after_save :set_block_record
  end

  # TODO: rename block_slots to blocks and get rid of this method
  def blocks
    # TODO: shouldn't need to reject blank? blocks, should fix this in the controller when saving
    @blocks ||= block_slots.includes(:block).collect(&:block)
  end

  # TODO: make this searchable
  def page_block_values
    self.block_record.slot_cache.collect { |a| JSON.parse(a[:block_as_json]).values }
  end

  # TODO: make this more performant and/or not as weird
  def reify_block_slots!
    self.block_slots = self.block_record.slot_cache.collect do |data|
      if data[:block_id]
        block = data[:block_type].constantize.find(data[:block_id])
        block.update_attributes JSON.parse(data[:block_as_json])
        BlockSlot.create page_id: self.id, block_id: data[:block_id], block_type: data[:block_type], position: data[:block_slot_position].to_i
      end
    end.reject(&:blank?)
  end

  def set_block_record_cache!
    set_slot_cache!
    set_block_cache!
  end

  def set_slot_cache!
    self.block_record.update_column :slot_cache, block_slots.includes(:block).collect { |block_slot|
      {
        block_slot_id: block_slot.id,
        block_id: block_slot.block_id,
        block_type: block_slot.block_type,
        block_slot_position: block_slot.position,
        block_as_json: (block_slot.block.as_json.reject { |a| block_slot_cache_blacklist_attributes.include? a }.to_json if block_slot.block)
      }
    }
  end

  def set_block_cache!
    self.block_record.update_column :block_cache, page_block_values
  end

  private

    def set_block_record
      record = self.block_record || self.build_block_record
      record.save
    end

    def block_slot_cache_blacklist_attributes
      %w(id created_at updated_at)
    end

end
