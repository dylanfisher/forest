class CreateForestSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :forest_sessions do |t|
      t.references :forest_user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
