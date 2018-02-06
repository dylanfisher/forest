class CreateCacheRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :cache_records do |t|
      t.integer :cacheable_id
      t.string :cacheable_type

      t.jsonb :data

      t.timestamps
    end

    add_index :cache_records, [:cacheable_type, :cacheable_id], name: 'index_cache_records_on_type_and_id'
  end
end
