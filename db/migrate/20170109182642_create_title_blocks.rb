class CreateTitleBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :title_blocks do |t|
      t.string :title

      t.timestamps
    end
  end
end
