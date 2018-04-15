class AddRedirectToPages < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :redirect, :string
  end
end
