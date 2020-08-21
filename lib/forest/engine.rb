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

    config.assets.paths << Pagy.root.join('javascripts')

    initializer :assets, group: :all do
      Rails.application.config.assets.precompile += %w(
        forest/application.css
        forest/bootstrap.css
        forest/application.js
        bootstrap-icons.svg
      )

      Rails.application.config.assets.precompile.concat Dir.glob(Forest::Engine.root.join('app', 'assets', 'images', 'bootstrap', '*.svg'))
    end
    initializer 'forest.checking_migrations' do
      Migrations.new(config, engine_name).check
    end

    config.before_configuration do
      require 'forest/shrine'
    end

    config.after_initialize do
      if database_exists?
        ActiveRecord::Base.connection_pool.with_connection do |c|
          unless Migrations.new(config, engine_name).missing_migrations.present? || c.migration_context.needs_migration?
            Setting.initialize_from_i18n if c.data_source_exists? 'settings'
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
