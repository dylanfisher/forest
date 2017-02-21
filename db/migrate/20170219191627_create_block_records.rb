class CreateBlockRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :block_records do |t|
      t.references :block_record, polymorphic: true, index: false

      t.index [:block_record_type, :block_record_id], name: 'index_block_records_on_block_record_type_and_block_record_id'
      t.index [:block_record_id, :block_record_type], name: 'index_block_records_on_block_record_id_and_block_record_type'

      t.text :slot_cache
      t.text :block_cache

      t.timestamps
    end
  end
end
