class CreateTranslations < ActiveRecord::Migration[5.1]
  def change
    create_table :translations do |t|
      t.string :key, null: false
      t.text :value, null: false
      t.text :description

      t.timestamps
    end
    add_index :translations, :key, unique: true
  end
end
