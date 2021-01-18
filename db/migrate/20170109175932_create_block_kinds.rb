class CreateBlockKinds < ActiveRecord::Migration[5.0]
  def change
    create_table :block_kinds do |t|
      t.string :name
      t.string :category
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    add_index :block_kinds, :name, unique: true
    add_index :block_kinds, :category
  end
end
