class CreateJoinTableUserGroupsUsers < ActiveRecord::Migration[5.0]
  def change
    create_join_table :user_groups, :users do |t|
      t.index [:user_group_id, :user_id]
      t.index [:user_id, :user_group_id]
    end
  end
end
