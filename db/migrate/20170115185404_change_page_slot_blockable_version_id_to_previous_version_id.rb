class ChangePageSlotBlockableVersionIdToPreviousVersionId < ActiveRecord::Migration[5.0]
  def change
    remove_index :page_slots, name: :index_page_slots_on_blockable_type_and_blockable_version_id
    remove_index :page_slots, name: :index_page_slots_on_blockable_version_id_and_blockable_type

    rename_column :page_slots, :blockable_version_id, :blockable_previous_version_id
  end
end
