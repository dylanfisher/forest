class AddPointOfInterestToMediaItems < ActiveRecord::Migration[6.0]
  def change
    add_column :media_items, :point_of_interest_x, :float, default: 50
    add_column :media_items, :point_of_interest_y, :float, default: 50
  end
end
