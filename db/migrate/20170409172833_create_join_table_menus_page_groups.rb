class CreateJoinTableMenusPageGroups < ActiveRecord::Migration[5.0]
  def change
    create_join_table :menus, :page_groups do |t|
      t.index [:menu_id, :page_group_id]
      t.index [:page_group_id, :menu_id]
    end
  end
end
