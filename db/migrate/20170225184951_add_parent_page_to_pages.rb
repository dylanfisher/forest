class AddParentPageToPages < ActiveRecord::Migration[5.0]
  def change
    add_reference :pages, :parent_page
  end
end
