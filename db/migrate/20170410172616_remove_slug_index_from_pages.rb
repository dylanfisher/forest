class RemoveSlugIndexFromPages < ActiveRecord::Migration[5.0]
  def self.up
    remove_index :pages, :slug if index_exists?(:pages, :slug)
    add_index :pages, :slug
    add_index :pages, [:slug, :parent_page_id]
  end
end
