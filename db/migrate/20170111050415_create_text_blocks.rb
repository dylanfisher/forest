class CreateTextBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :text_blocks do |t|
      t.text :text

      t.timestamps
    end

    reversible do |change|
      change.up do
        BlockType.find_or_create_by(name: 'TextBlock')
      end

      change.down do
        BlockType.find_by_name('TextBlock')&.delete
      end
    end
  end
end
