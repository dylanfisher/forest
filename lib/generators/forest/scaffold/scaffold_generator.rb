require "rails/generators/rails/resource/resource_generator"

class Forest::ScaffoldGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

  def self.next_migration_number(dirname)
    next_migration_number = current_migration_number(dirname) + 1
    ActiveRecord::Migration.next_migration_number(next_migration_number)
  end

  def create_model_file
    template 'model.rb', File.join('app/models', "#{file_name}.rb")
  end

  def create_view_files
    available_views.each do |view|
      filename = "#{view}.html.erb"
      template "views/#{filename}", File.join("app/views", plural_name, filename)
    end
  end

  def create_migration_file
    set_local_assigns!
    validate_file_name!
    migration_template 'create_table_migration.rb', "db/migrate/create_#{table_name}.rb"
  end

  def create_controller
    template 'controller.rb', "app/controllers/#{plural_name}_controller.rb"
    route_lines = []
    route_lines << "# TODO: sort these new routes"
    route_lines << "  scope :admin do"
    route_lines << "    resources :#{plural_name}"
    route_lines << "  end"
    route_lines << "  get '#{singular_name}/:id', to: '#{plural_name}#show', as: 'show_#{singular_name}'\n"

    route route_lines.join("\n")
  end

  def create_policy
    template 'policy.rb', "app/policies/#{singular_name}_policy.rb"
  end

  private

    attr_reader :migration_action, :join_tables

    # Sets the default migration template that is being used for the generation of the migration.
    # Depending on command line arguments, the migration template and the table name instance
    # variables are set up.
    def set_local_assigns!
      @migration_template = "migration.rb"
      case file_name
      when /^(add|remove)_.*_(?:to|from)_(.*)/
        @migration_action = $1
        @table_name       = normalize_table_name($2)
      when /join_table/
        if attributes.length == 2
          @migration_action = "join"
          @join_tables      = pluralize_table_names? ? attributes.map(&:plural_name) : attributes.map(&:singular_name)

          set_index_names
        end
      when /^create_(.+)/
        @table_name = normalize_table_name($1)
        @migration_template = "create_table_migration.rb"
      end
    end

    def set_index_names
      attributes.each_with_index do |attr, i|
        attr.index_name = [attr, attributes[i - 1]].map { |a| index_name_for(a) }
      end
    end

    def index_name_for(attribute)
      if attribute.foreign_key?
        attribute.name
      else
        attribute.name.singularize.foreign_key
      end.to_sym
    end

    def attributes_with_index
      attributes.select { |a| !a.reference? && a.has_index? }
    end

    # A migration file name can only contain underscores (_), lowercase characters,
    # and numbers 0-9. Any other file name will raise an IllegalMigrationNameError.
    def validate_file_name!
      unless /^[_a-z0-9]+$/.match?(file_name)
        raise IllegalMigrationNameError.new(file_name)
      end
    end

    def normalize_table_name(_table_name)
      pluralize_table_names? ? _table_name.pluralize : _table_name.singularize
    end

    def available_views
      %w(_form edit index new show versions)
    end
end
