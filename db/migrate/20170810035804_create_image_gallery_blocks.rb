class CreateImageGalleryBlocks < ActiveRecord::Migration[5.1]
  def change
    create_table :image_gallery_blocks do |t|
      t.timestamps
    end

    reversible do |change|
      change.up do
        unless BlockType.find_by_name('ImageGalleryBlock')
          BlockType.create name: 'ImageGalleryBlock',
                           category: 'default',
                           description: ''
        end
      end

      change.down do
        BlockType.where(name: 'ImageGalleryBlock').destroy_all
        BlockSlot.where(block_type: 'ImageGalleryBlock').destroy_all
      end
    end
  end
end
