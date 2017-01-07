class SeedUserGroups < ActiveRecord::Migration[5.0]
  def up
    UserGroup.find_or_create_by(name: 'admin')
    UserGroup.find_or_create_by(name: 'editor')
    UserGroup.find_or_create_by(name: 'contributor')
  end
end
