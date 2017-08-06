class BlockSlot < Forest::ApplicationRecord
  belongs_to :block, polymorphic: true
  belongs_to :block_record, polymorphic: true

  has_paper_trail class_name: 'BlockSlotVersion',
                  meta: {
                    # block_record_version: :set_block_record_version,
                    block_record_id: :block_record_id,
                    block_record_type: :block_record_type,
                    blocks: :set_versionable_blocks
                  }

  def update_block_record_version!
    if self.versions.last.block_record_version.nil?
      self.versions.last.update_columns(block_record_version: self.block_record.latest_version_number)
    end
  end

  private

    # def set_block_record_version
    #   self.block_record.latest_version_number
    # end

    # TODO: DF 08/06/17 - is there a reason to store this information here?
    def set_versionable_blocks
      self.block.as_json
    end
end
