class Forest::BlockGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

  def self.next_migration_number(dirname)
    next_migration_number = current_migration_number(dirname) + 1
    ActiveRecord::Migration.next_migration_number(next_migration_number)
  end

  def create_model_file
    template 'model.rb', File.join('app/models/blocks', "#{file_name}.rb")
  end

  def create_view_files
    template "_block.html.erb", File.join('app/views/blocks', file_name, "_show.html.erb")
    template "_block_edit_fields.html.erb", File.join('app/views/blocks', file_name, "_edit.html.erb")
  end

  def create_migration_file
    set_local_assigns!
    validate_file_name!
    migration_template 'create_table_migration.rb', "db/migrate/create_#{table_name}.rb"
  end

  def create_stylesheet
    template '_block.scss.erb', File.join('app/assets/stylesheets/blocks', "_#{file_name}.scss")
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

  def block_record_type
    escape_quotes (ENV['BLOCK_RECORD_TYPE'].presence || 'default')
  end

  def block_category
    escape_quotes (ENV['BLOCK_CATEGORY'].presence || 'default')
  end

  def block_description
    escape_quotes (ENV['BLOCK_DESCRIPTION'].presence || '')
  end

  def escape_quotes(string)
    string.gsub(/[']/, '\\\\\'')
  end
end
