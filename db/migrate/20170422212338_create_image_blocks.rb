class CreateImageBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :image_blocks do |t|
      t.integer :image_id
      t.text :caption

      t.timestamps
    end

    reversible do |change|
      change.up do
        unless BlockKind.find_by_name('ImageBlock')
          BlockKind.create name: 'ImageBlock',
                           category: 'default',
                           description: ''
        end
      end

      change.down do
        BlockKind.where(name: 'ImageBlock').destroy_all
        BlockSlot.where(block_kind: 'ImageBlock').destroy_all
      end
    end
  end
end
