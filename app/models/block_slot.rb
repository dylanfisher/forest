class BlockSlot < ApplicationRecord
  belongs_to :block, polymorphic: true
  belongs_to :block_record, polymorphic: true

  after_save :update_block_record

  private

    def update_block_record
      # block_record
    end
end
