class RemoveAttachableFromMediaItems < ActiveRecord::Migration[5.0]
  def change
    remove_index :media_items, column: [:attachable_type, :attachable_id]
    remove_column :media_items, :attachable_type, :string
    remove_column :media_items, :attachable_id, :integer
  end
end
