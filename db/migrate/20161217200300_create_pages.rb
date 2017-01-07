class CreatePages < ActiveRecord::Migration[5.0]
  def change
    create_table :pages do |t|
      t.string :title
      t.string :slug
      t.text :description

      t.timestamps
    end
    add_index :pages, :slug, unique: true
  end
end
