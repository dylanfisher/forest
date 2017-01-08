class AddFeaturedImageToPages < ActiveRecord::Migration[5.0]
  def change
    add_reference :pages, :featured_image
  end
end
