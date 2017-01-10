class CreatePageSlots < ActiveRecord::Migration[5.0]
  def change
    create_table :page_slots do |t|
      t.integer :page_id
      t.integer :page_version_id
      t.integer :blockable_id
      t.string :blockable_type
      t.integer :blockable_version_id

      t.index :page_id
      t.index :page_version_id
      t.index [:blockable_id, :blockable_type]
      t.index [:blockable_type, :blockable_id]
      t.index [:blockable_version_id, :blockable_type]
      t.index [:blockable_type, :blockable_version_id]

      t.timestamps
    end
  end
end
