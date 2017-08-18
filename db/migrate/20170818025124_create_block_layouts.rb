class CreateBlockLayouts < ActiveRecord::Migration[5.1]
  def change
    create_table :block_layouts do |t|
      t.string :slug
      t.string :display_name
      t.text :description

      t.timestamps
    end

    add_index :block_layouts, :slug
  end
end
