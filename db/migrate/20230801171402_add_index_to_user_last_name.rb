class AddIndexToUserLastName < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :last_name
  end
end
