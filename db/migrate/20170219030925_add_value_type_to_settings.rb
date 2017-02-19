class AddValueTypeToSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :settings, :value_type, :string, default: 'text'
  end
end
