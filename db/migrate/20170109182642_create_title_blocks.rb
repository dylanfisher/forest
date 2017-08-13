class CreateTitleBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :title_blocks do |t|
      t.string :title

      t.timestamps
    end

    reversible do |change|
      change.up do
        BlockKind.find_or_create_by(name: 'TitleBlock')
      end

      change.down do
        BlockKind.find_by_name('TitleBlock')&.delete
      end
    end
  end
end
