class CreateImageBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :image_blocks do |t|
      t.integer :image_id
      t.text :caption

      t.timestamps
    end

    reversible do |change|
      change.up do
        unless BlockType.find_by_name('ImageBlock')
          BlockType.create name: 'ImageBlock',
                           category: 'default',
                           description: ''
        end
      end

      change.down do
        BlockType.where(name: 'ImageBlock').destroy_all
        BlockSlot.where(block_type: 'ImageBlock').destroy_all
      end
    end
  end
end
