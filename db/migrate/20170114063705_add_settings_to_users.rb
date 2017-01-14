class AddSettingsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :settings, :text, null: false, default: {}.to_json
  end
end
