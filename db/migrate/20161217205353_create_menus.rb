class CreateMenus < ActiveRecord::Migration[5.0]
  def change
    create_table :menus do |t|
      t.string :title
      t.string :slug
      t.text :structure

      t.timestamps
    end
    add_index :menus, :slug, unique: true
  end
end
