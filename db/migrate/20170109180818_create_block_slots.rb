class CreateBlockSlots < ActiveRecord::Migration[5.0]
  def change
    create_table :block_slots do |t|
      t.integer :block_id, null: false
      t.string :block_type, null: false

      t.references :block_record, polymorphic: true, index: true

      t.integer :block_version_id

      t.integer :position, default: 0, null: false

      t.index [:block_id, :block_type]
      t.index [:block_type, :block_id]
      t.index [:block_version_id, :block_type]
      t.index [:block_type, :block_version_id]

      t.timestamps
    end
  end
end
