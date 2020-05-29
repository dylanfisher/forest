Gem.loaded_specs['forest'].runtime_dependencies.each do |dependency|
  begin
    require dependency.name
  rescue LoadError => load_error
    # Put exceptions here.
    # raise load_error if dependency.name !~ /gem_name/
  end
end

module Forest
  class Engine < ::Rails::Engine
    config.autoload_paths << "#{config.root}/app/models/blocks"

    initializer :assets, group: :all do
      Rails.application.config.assets.precompile += %w(
        forest/application_admin.css
        forest/application_public.css
        forest/application_bootstrap.css
        forest/application_admin.js
        forest/application_public.js
        forest/lib/jquery-3.3.1.min.js
        forest/favicons/apple-touch-icon.png
        forest/favicons/favicon-32x32.png
        forest/favicons/favicon-16x16.png
        forest/favicons/manifest.json
        forest/favicons/safari-pinned-tab.svg
      )
    end

    initializer 'forest.checking_migrations' do
      Migrations.new(config, engine_name).check
    end

    # https://github.com/rails/webpacker/blob/master/docs/engines.md
    initializer "webpacker.proxy" do |app|
      insert_middleware = begin
                          Forest.webpacker.config.dev_server.present?
                        rescue
                          nil
                        end
      next unless insert_middleware

      app.middleware.insert_before(
        0, Webpacker::DevServerProxy, # "Webpacker::DevServerProxy" if Rails version < 5
        ssl_verify_none: true,
        webpacker: Forest.webpacker
      )
    end

    config.after_initialize do
      if database_exists?
        ActiveRecord::Base.connection_pool.with_connection do |c|
          unless Migrations.new(config, engine_name).missing_migrations.present? || c.migration_context.needs_migration?
            Setting.initialize_from_i18n if c.data_source_exists? 'settings'
            Translation.initialize_from_i18n if c.data_source_exists? 'translations'
          end
        end
      end
    end

    def database_exists?
      ActiveRecord::Base.connection
    rescue ActiveRecord::NoDatabaseError
      false
    else
      true
    end
  end
end
