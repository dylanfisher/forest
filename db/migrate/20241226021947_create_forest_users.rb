class CreateForestUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :forest_users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index :forest_users, :email_address, unique: true
  end
end
