class CreateTextBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :text_blocks do |t|
      t.text :text

      t.timestamps
    end

    reversible do |change|
      change.up do
        unless BlockKind.find_by_name('TextBlock')
          BlockKind.create(name: 'TextBlock', category: 'Default', description: "A general purpose block for adding text to a page.")
        end
      end

      change.down do
        BlockKind.where(name: 'TextBlock').destroy_all
        BlockSlot.where(block_kind: 'TextBlock').destroy_all
      end
    end
  end
end
