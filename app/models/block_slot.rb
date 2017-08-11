class BlockSlot < Forest::ApplicationRecord
  belongs_to :block, polymorphic: true, dependent: :destroy
  belongs_to :block_record, polymorphic: true
end
