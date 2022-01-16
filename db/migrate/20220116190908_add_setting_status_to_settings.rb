class AddSettingStatusToSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :settings, :setting_status, :integer, default: 0
    add_index :settings, :setting_status
  end
end
