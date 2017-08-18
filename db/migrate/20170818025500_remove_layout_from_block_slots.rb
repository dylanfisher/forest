class RemoveLayoutFromBlockSlots < ActiveRecord::Migration[5.1]
  def change
    remove_column :block_slots, :layout, :string
  end
end
