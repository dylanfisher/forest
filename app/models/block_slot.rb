class BlockSlot < Forest::ApplicationRecord
  belongs_to :block, polymorphic: true
  belongs_to :block_record, polymorphic: true

  # TODO: DF 08/05/17 - need to store block version id

  has_paper_trail class_name: 'BlockSlotVersion',
                  meta: {
                    block_record_id: :block_record_id,
                    blocks: :set_versionable_blocks
                  }

  private

    def set_versionable_blocks
      self.block.as_json
    end
end
