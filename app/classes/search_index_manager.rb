# Does not support Elasticsearch version > 5

class SearchIndexManager
  # A single combined index name is used for environments like Heroku where multiple
  # shards are expensive.
  INDEX_NAME = "#{Rails.app_class.parent_name.underscore}_#{Rails.env}".freeze

  # Override this in your host app with an array of all the models you want to search.
  # For example:
  #
  # SearchIndexManager.class_eval do
  #   def self.indexed_models
  #     [Page, Spree::Product]
  #   end
  # end
  def self.indexed_models
    []
  end

  def self.index_names
    if Elasticsearch::Rails::VERSION.to_i < 6
      [INDEX_NAME]
    else
      indexed_models.collect(&:index_name)
    end
  end

  def self.create_index(options = {})
    settings = indexed_models.map(&:settings).reduce({}, &:merge)
    mappings = indexed_models.map(&:mappings).reduce({}, &:merge)

    delete_index! if options[:force]

    index_names.each do |index_name|
      logger.debug { "[Forest] Creating index #{index_name} with configuration:" }
      logger.debug { "[Forest] -- Settings #{settings.inspect}" }
      logger.debug { "[Forest] -- Mappings #{mappings.inspect}" }
      create index: index_name, body: { settings: settings, mappings: mappings }
    end
  end

  def self.delete_index!
    index_names.each do |index_name|
      if exists? index: index_name
        logger.debug { "[Forest] Deleting index #{index_name}" }
        delete index: index_name
      end
    end
  end

  def self.refresh_index
    index_names.each do |index_name|
      if exists? index: index_name
        logger.debug { "[Forest] Refreshing index #{index_name}" }
        refresh index: index_name
      end
    end
  end

  def self.rebuild
    options = { force: true }
    create_index(options)
    import
  end

  def self.import(options = {})
    models_to_index = options[:models] || indexed_models

    if (models_to_index - indexed_models).present?
      raise TypeError, 'The :models option cannot contain non-indexed models'
    end

    models_to_index.each do |model|
      logger.debug { "[Forest] importing model #{model.name}#{' (using `' + model_scope(model).to_s + '` scope)' if model_scope(model).present?}" }
      model.import batch_size: 500, scope: model_scope(model)
    end
  end

  class << self
    private

    delegate :create, :exists?, :delete, :refresh, to: :indices

    def indices
      Elasticsearch::Model.client.indices
    end

    def model_scope(klass)
      klass.elasticsearch_import_model_scope
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
