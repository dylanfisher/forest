class AddBlockableRecordReferenceToPageSlots < ActiveRecord::Migration[5.0]
  def change
    add_reference :page_slots, :blockable_record, polymorphic: true, index: false

    add_index :page_slots, [:blockable_record_type, :blockable_record_id], name: 'index_page_slots_on_block_record_type_and_block_record_id'
    add_index :page_slots, [:blockable_record_id, :blockable_record_type], name: 'index_page_slots_on_block_record_id_and_block_record_type'
  end
end
