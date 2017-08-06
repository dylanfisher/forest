class BlockSlotVersion < PaperTrail::Version
  self.table_name = :block_slot_versions
  self.sequence_name = :block_slot_versions_id_seq

  # belongs_to :block_record, polymorphic: true

  # TODO: DF 08/05/17 - need to store block version id

  # TODO: create association to achieve this?
  def block_record
    # self.reify.block_record.versions.find(block_record_version_id)
  end
end
