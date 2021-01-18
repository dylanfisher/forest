class DropDimensionsFromMediaItems < ActiveRecord::Migration[6.0]
  def change
    remove_column :media_items, :dimensions, :text
  end
end
