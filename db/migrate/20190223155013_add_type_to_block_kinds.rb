class AddTypeToBlockKinds < ActiveRecord::Migration[5.2]
  def change
    add_column :block_kinds, :record_type, :string
    add_index :block_kinds, :record_type
  end
end
