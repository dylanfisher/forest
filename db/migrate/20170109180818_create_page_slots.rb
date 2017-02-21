class CreatePageSlots < ActiveRecord::Migration[5.0]
  def change
    create_table :page_slots do |t|
      t.integer :page_id
      t.integer :page_version_id
      t.integer :block_id
      t.string :block_type
      t.integer :block_version_id
      t.text :page_slot_cache
      t.integer :position, default: 0, null: false

      t.index :page_id
      t.index :page_version_id
      t.index [:block_id, :block_type]
      t.index [:block_type, :block_id]
      t.index [:block_version_id, :block_type]
      t.index [:block_type, :block_version_id]

      t.timestamps
    end

    add_reference :page_slots, :block_record, polymorphic: true, index: false
    add_index :page_slots, [:block_record_type, :block_record_id], name: 'index_page_slots_on_block_record_type_and_block_record_id'
    add_index :page_slots, [:block_record_id, :block_record_type], name: 'index_page_slots_on_block_record_id_and_block_record_type'
  end
end
