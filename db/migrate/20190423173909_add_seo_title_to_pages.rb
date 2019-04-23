class AddSeoTitleToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :seo_title, :string
  end
end
