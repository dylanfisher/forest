class CreatePages < ActiveRecord::Migration[5.0]
  def change
    create_table :pages do |t|
      t.string :title
      t.string :slug
      t.text :path
      t.integer :status, default: 1, null: false
      t.datetime :scheduled_date
      t.text :description

      t.timestamps
    end

    add_reference :pages, :featured_image
    add_reference :pages, :parent_page
    add_index :pages, :slug
    add_index :pages, :status
    add_index :pages, :path, unique: true
  end

end
