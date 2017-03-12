class CreatePageGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :page_groups do |t|
      t.string :title
      t.string :slug, index: true
      t.integer :level, default: 0, null: false

      t.references :page, index: true
      t.references :parent_page, index: true
      t.references :ancestor_page, index: true
    end
  end
end
