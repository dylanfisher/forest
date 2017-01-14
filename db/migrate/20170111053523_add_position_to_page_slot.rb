class AddPositionToPageSlot < ActiveRecord::Migration[5.0]
  def change
    add_column :page_slots, :position, :integer, null: false, default: 0
  end
end
