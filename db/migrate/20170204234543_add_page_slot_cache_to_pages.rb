class AddPageSlotCacheToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :page_slot_cache, :text
  end
end
