class AddLocaleToSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :settings, :locale, :string
    add_index :settings, :locale
  end
end
