class BlockableRecord < ApplicationRecord
  serialize :slot_cache
  serialize :block_cache

  belongs_to :blockable_record, polymorphic: true

  def page_slots
    blockable_record.page_slots
  end
end
