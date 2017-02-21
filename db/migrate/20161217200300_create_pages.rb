class CreatePages < ActiveRecord::Migration[5.0]
  def change
    create_table :pages do |t|
      t.string :title
      t.string :slug
      t.text :description
      t.integer :status, default: 1, null: false

      t.timestamps
    end

    add_reference :pages, :featured_image
    add_index :pages, :slug, unique: true
    add_index :pages, :status
  end

end
