# Does not support Elasticsearch version > 6

class SearchIndexManager
  INDEX_NAME = "#{Rails.app_class.parent_name.underscore}_#{Rails.env}".freeze

  # Override this in your host app with an array of all the models you want to search
  def self.indexed_models
    []
  end

  def self.create_index(options = {})
    settings = indexed_models.map(&:settings).reduce({}, &:merge)
    mappings = indexed_models.map(&:mappings).reduce({}, &:merge)

    if options[:force]
      logger.debug { "[Forest] Deleting index #{INDEX_NAME}" }
      delete_index!
    end

    logger.debug { "[Forest] -- Settings #{settings.inspect}" }
    logger.debug { "[Forest] -- Mappings #{mappings.inspect}" }
    logger.debug { "[Forest] Creating index #{INDEX_NAME}" }
    create index: INDEX_NAME, body: { settings: settings, mappings: mappings }
  end

  def self.delete_index!
    if exists? index: INDEX_NAME
      delete index: INDEX_NAME
    end
  end

  def self.refresh_index
    if exists? index: INDEX_NAME
      refresh index: INDEX_NAME
    end
  end

  def self.rebuild(options = {})
    options.merge!(force: true)
    create_index(options)
    import(options)
  end

  def self.import(options = {})
    models_to_index = options[:models] || indexed_models

    if (models_to_index - indexed_models).present?
      raise TypeError, 'The :models option cannot contain non-indexed models'
    end

    models_to_index.each do |model|
      logger.debug { "[Forest] importing model #{model.name}#{' (using `' + model_scope(model).to_s + '` scope)' if model_scope(model).present?}" }
      model.import batch_size: 500, scope: model_scope(model), force: options[:force]
    end
  end

  class << self
    private

    delegate :create, :exists?, :delete, :refresh, to: :indices

    def indices
      Elasticsearch::Model.client.indices
    end

    def model_scope(klass)
      if klass.try(:statusable?)
        :published
      end
    end

    def eager_load!
      @eager_load ||= begin
        Dir["#{Forest::Engine.root}/app/models/*.rb"].each { |file| load file }
        Rails.application.eager_load!
      end
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
