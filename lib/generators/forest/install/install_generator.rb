module Forest
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      # TODO: the install generator should:
      #   - seed default settings
      #   - install forest's migrations, or prompt the user to do this

      puts "[Forest] Install Generator"
      puts "[Forest] -- Seeding database"

      puts "[Forest] ---- Creating default settings"
      Setting.find_or_create_by title: 'Site Title', value: 'Default Site Title'
      Setting.find_or_create_by title: 'Description', value: 'A Site Built With Forest'
      Setting.find_or_create_by title: 'Featured Image', value: nil, value_type: 'image', description: "The featured image may be used when sharing the site on social media."

      puts "[Forest] ---- Creating user groups"
      UserGroup.find_or_create_by(name: 'admin')
      UserGroup.find_or_create_by(name: 'editor')
      UserGroup.find_or_create_by(name: 'contributor')
    end
  end
end
