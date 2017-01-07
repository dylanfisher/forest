class CreateDefaultSettings < ActiveRecord::Migration[5.0]
  def up
    Setting.find_or_create_by title: 'Site Title', value: 'Default Site Title'
    Setting.find_or_create_by title: 'Description', value: 'A Site Built With Forest'
    Setting.find_or_create_by title: 'Featured Image', value: nil
  end
end
