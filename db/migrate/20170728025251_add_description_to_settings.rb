class AddDescriptionToSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :settings, :description, :text
  end
end
