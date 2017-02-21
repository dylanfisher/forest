class BlockRecord < ApplicationRecord
  serialize :slot_cache
  serialize :block_cache

  belongs_to :block_record, polymorphic: true

  def page_slots
    block_record.page_slots
  end
end
