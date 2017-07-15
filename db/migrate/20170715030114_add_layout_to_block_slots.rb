class AddLayoutToBlockSlots < ActiveRecord::Migration[5.1]
  def change
    add_column :block_slots, :layout, :string
    add_index :block_slots, :layout
  end
end
