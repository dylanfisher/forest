module Forest
  class Migrations
    attr_reader :config, :engine_name

    # Initialize with engine config and engine name
    def initialize(config, engine_name)
      @config = config
      @engine_name = engine_name
    end

    # Check for missing migrations and output warnings
    def check
      missing = missing_migrations

      return if missing.empty?

      log_warning("✋ Warning: missing migrations.")
      missing.each { |migration| log_warning("-- #{migration} from #{engine_name} is missing.") }
      log_warning("Run the following command to get them.")
      log_warning("bundle exec rake railties:install:migrations\n\n")
    end

    def missing_migrations
      return [] unless File.directory?(app_dir)

      app_migration_names = app_migrations.map { |file| parse_migration_name(file) }.compact
      engine_migration_names = engine_migrations.map { |file| parse_migration_name(file) }.compact

      engine_migration_names - app_migration_names
    end

    def missing_migrations?
      missing_migrations.present?
    end

    private

    def app_migrations
      fetch_migration_files(app_dir)
    end

    def engine_migrations
      fetch_migration_files(engine_dir)
    end

    def fetch_migration_files(dir)
      Pathname.new(dir).children
                .select { |file| file.file? && !ignored?(file) }
    end

    def parse_migration_name(file)
      parts = file.basename.to_s.split('_', 2)
      parts[1]&.split('.', 2)&.first
    end

    def ignored?(file)
      files_to_ignore.any? { |pattern| file.to_s =~ /#{pattern}/i }
    end

    def app_dir
      Rails.root.join("db", "migrate")
    end

    def engine_dir
      config.root.join("db", "migrate")
    end

    def files_to_ignore
      [".DS_STORE"]
    end

    def engine_display_name
      engine_name.capitalize.sub(/_engine/, "")
    end

    def log_warning(message)
      puts "[#{engine_display_name}] #{message}"
    end
  end
end
