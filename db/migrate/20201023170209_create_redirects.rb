class CreateRedirects < ActiveRecord::Migration[6.0]
  def change
    create_table :redirects do |t|
      t.string :name
      t.string :from_path
      t.string :to_path
      t.string :redirect_type
      t.integer :status, default: 1, null: false

      t.timestamps
    end

    add_index :redirects, :status
    add_index :redirects, :from_path
    add_index :redirects, [:status, :from_path]
    add_index :redirects, :to_path
  end
end
