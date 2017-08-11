class CreateImageGalleryBlockImages < ActiveRecord::Migration[5.1]
  def change
    create_table :image_gallery_block_images do |t|
      t.references :image_gallery_block, index: true, foreign_key: true
      t.references :image, index: true, foreign_key: false
      t.integer :position

      t.timestamps
    end
  end
end
