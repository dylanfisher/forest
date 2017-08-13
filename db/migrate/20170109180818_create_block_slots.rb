class CreateBlockSlots < ActiveRecord::Migration[5.0]
  def change
    create_table :block_slots do |t|
      t.references :block, polymorphic: true, index: true
      t.references :block_kind, index: true, foreign_key: true
      t.references :block_record, polymorphic: true, index: true

      t.string :layout

      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :block_slots, :layout
  end
end
