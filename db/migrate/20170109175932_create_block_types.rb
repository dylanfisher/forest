class CreateBlockTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :block_types do |t|
      t.string :name
      t.text :description
      t.string :category
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    add_index :block_types, :name, unique: true
  end
end
