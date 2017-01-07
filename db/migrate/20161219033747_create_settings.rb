class CreateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.string :title
      t.string :slug
      t.text :value

      t.timestamps
    end
    add_index :settings, :slug, unique: true
  end
end
