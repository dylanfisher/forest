class CreateTextBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :text_blocks do |t|
      t.text :text

      t.timestamps
    end

    reversible do |change|
      change.up do
        unless BlockType.find_by_name('TextBlock')
          BlockType.create(name: 'TextBlock', category: 'Default', description: "A general purpose block for adding text to a page.")
        end
      end

      change.down do
        BlockType.where(name: 'TextBlock').destroy_all
        PageSlot.where(blockable_type: 'TextBlock').destroy_all
      end
    end
  end
end
