class BlockRecord < ApplicationRecord
  serialize :slot_cache
  serialize :block_cache

  belongs_to :block_record, polymorphic: true

  def block_slots
    block_record.block_slots
  end
end
