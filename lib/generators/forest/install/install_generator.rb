module Forest
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      # TODO: the install generator should:
      #   - seed default settings
      #     - block kinds
      #   - install forest's migrations, or prompt the user to do this

      puts "[Forest] Install Generator"
      puts "[Forest] -- Seeding database"

      # Settings
      puts "[Forest] ---- Creating default settings"

      if Setting.find_by_title('Site Title').blank?
        Setting.create(title: 'Site Title', value: 'Default Site Title')
      end

      if Setting.find_by_title('Description').blank?
        Setting.create(title: 'Description', value: 'A Site Built With Forest')
      end

      if Setting.find_by_title('Featured Image').blank?
        Setting.create(title: 'Featured Image', value: nil, value_type: 'image', description: "The featured image may be used when sharing the site on social media.")
      end

      # User groups
      puts "[Forest] ---- Creating user groups"

      UserGroup.find_or_create_by(name: 'admin')
      UserGroup.find_or_create_by(name: 'editor')
      UserGroup.find_or_create_by(name: 'contributor')

      # Block layouts
      puts "[Forest] ---- Creating default block layouts"
      if BlockLayout.find_by_slug('default').blank?
        BlockLayout.create(slug: 'default', display_name: 'Default')
      end
    end

    puts "[Forest]"
    puts "[Forest] 🌲  all done!"
    puts "[Forest]"
    puts "[Forest] Post-install"

    # Prompt to install migrations
    puts "[Forest] -- Import Forest's migrations by running this command:"
    puts "[Forest] rails railties:install:migrations"

  end
end
