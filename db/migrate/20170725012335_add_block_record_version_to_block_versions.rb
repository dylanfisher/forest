class AddBlockRecordVersionToBlockVersions < ActiveRecord::Migration[5.1]
  def change
    add_column :block_versions, :block_record_version_id, :integer
    add_column :block_versions, :block_record_type, :string
    add_index :block_versions, :block_record_type
    add_index :block_versions, :block_record_version_id
  end
end
