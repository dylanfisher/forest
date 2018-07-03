class CreateForestVersions < ActiveRecord::Migration[5.1]
  def change
    create_table :versions do |t|
      t.references :record, polymorphic: true
      t.jsonb :original_attributes, default: {}

      t.timestamps
    end

    add_index :versions, :original_attributes, using: :gin
  end
end
