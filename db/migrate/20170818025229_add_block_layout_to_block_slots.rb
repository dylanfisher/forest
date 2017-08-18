class AddBlockLayoutToBlockSlots < ActiveRecord::Migration[5.1]
  def change
    add_reference :block_slots, :block_layout, foreign_key: true, index: true
  end
end
