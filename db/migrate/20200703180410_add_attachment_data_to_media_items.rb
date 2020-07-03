class AddAttachmentDataToMediaItems < ActiveRecord::Migration[5.0]
  def change
    add_column :media_items, :attachment_data, :jsonb
  end
end
