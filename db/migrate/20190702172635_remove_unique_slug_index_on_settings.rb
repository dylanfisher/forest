class RemoveUniqueSlugIndexOnSettings < ActiveRecord::Migration[5.0]
  def up
    remove_index :settings, :slug if index_exists?(:settings, :slug)

    add_index :settings, [:locale, :slug], unique: true
  end

  def down
    remove_index :settings, [:locale, :slug] if index_exists?(:settings, [:locale, :slug])

    add_index :settings, :slug, unique: true
  end
end
