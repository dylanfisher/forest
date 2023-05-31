class AddVideoDataToMediaItems < ActiveRecord::Migration[6.0]
  def change
    add_column :media_items, :video_data, :jsonb
  end
end
