class IndexAttachmentContentTypeOnMediaItems < ActiveRecord::Migration[5.1]
  def change
    add_index :media_items, :attachment_content_type
  end
end
