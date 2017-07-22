class BlockVersion < PaperTrail::Version
  self.table_name = :block_versions
  self.sequence_name = :block_versions_id_seq
end
