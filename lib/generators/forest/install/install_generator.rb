module Forest
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      # TODO: the install generator should:
      #   - seed default settings
      #     - block kinds
      #   - install forest's migrations, or prompt the user to do this

      puts "[Forest] Install Generator"

      # Prompt to install migrations
      if ActiveRecord::Base.connection.table_exists? 'settings'
        puts "[Forest] -- Seeding database"

        # Pages
        puts "[Forest] ---- Creating default home page"
        if Page.find_by_slug('home').blank?
          Page.create(title: 'Home')
        end

        # Settings
        puts "[Forest] ---- Creating default settings"

        if Setting.find_by_title('Site Title').blank?
          Setting.create(title: 'Site Title', value: 'Default Site Title', value_type: 'string')
        end

        if Setting.find_by_title('Description').blank?
          Setting.create(title: 'Description', value: 'A Site Built With Forest')
        end

        if Setting.find_by_title('Featured Image').blank?
          Setting.create(title: 'Featured Image', value: nil, value_type: 'image', description: "The featured image may be used when sharing the site on social media.")
        end

        # TODO
        # if Setting.find_by_title('Locales').blank?
        #   Setting.create(title: 'Locales', value: [:en], value_type: 'array')
        # end

        # User groups
        puts "[Forest] ---- Creating user groups"

        UserGroup.find_or_create_by(name: 'admin')
        UserGroup.find_or_create_by(name: 'editor')
        UserGroup.find_or_create_by(name: 'contributor')

        # Block layouts
        puts "[Forest] ---- Creating default block layouts"
        if BlockLayout.find_by_slug('default').blank?
          BlockLayout.create(slug: 'default', display_name: 'Content Blocks', description: "")
        end

        puts "[Forest]"
        puts "[Forest] 🌲  all done!"
        puts "[Forest]"
        puts "[Forest] Post-install"

        # Application config
        puts "[Forest] -- Add the following to application.rb"
        puts '[Forest] config.autoload_paths << "#{config.root}/app/models/blocks"'

        # Create your first block
        puts "[Forest] -- Create a Block by running this command:"
        puts '[Forest] rails g forest:block TextBlock text:text'

        # Visit the site and create an admin user
        puts "[Forest] -- Visit the admin area of the website at localhost:3000/admin to create the admin user."
      else
        puts "[Forest] -- ✋  Import Forest's migrations by running the following command."
        puts "[Forest] -- After installing migrations, run this generator again to seed the database."
        puts "[Forest] rails railties:install:migrations"
      end
    end
  end
end
