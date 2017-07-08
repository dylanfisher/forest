class AddScheduledDateToPage < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :scheduled_date, :datetime
  end
end
