class BlockVersion < PaperTrail::Version
  self.table_name = :block_versions
  self.sequence_name = :block_versions_id_seq

  before_save :set_block_record_data

  # TODO: create association to achieve this?
  def block_record
    self.reify.block_record.versions.find(block_record_version_id)
  end

  private

    def set_block_record_data
      self.block_record_version_id = self.reify.block_record.current_version.id
      self.block_record_type = self.reify.block_record.current_version.item_type
    end
end
