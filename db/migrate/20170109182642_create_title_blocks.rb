class CreateTitleBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :title_blocks do |t|
      t.string :title

      t.timestamps
    end

    reversible do |change|
      change.up do
        BlockType.find_or_create_by(name: 'TitleBlock')
      end

      change.down do
        BlockType.find_by_name('TitleBlock')&.delete
      end
    end
  end
end
