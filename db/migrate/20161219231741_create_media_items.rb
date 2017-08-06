class CreateMediaItems < ActiveRecord::Migration[5.0]
  def change
    create_table :media_items do |t|
      t.string :title
      t.string :slug
      t.text :caption
      t.string :alternative_text
      t.text :description
      t.text :dimensions
      t.attachment :attachment

      t.references :attachable, polymorphic: true, index: true

      t.timestamps
    end
    add_index :media_items, :slug, unique: true
  end
end
