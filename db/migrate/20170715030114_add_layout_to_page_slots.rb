class AddLayoutToPageSlots < ActiveRecord::Migration[5.1]
  def change
    add_column :page_slots, :layout, :string
    add_index :page_slots, :layout
  end
end
