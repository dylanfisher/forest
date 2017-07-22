class BlockSlot < ApplicationRecord
  belongs_to :block, polymorphic: true
  belongs_to :block_record, polymorphic: true
end
