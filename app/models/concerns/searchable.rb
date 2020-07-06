# This module provides a search interface to the record using elasticsearch-rails.
# The easiest way to implement search in your host app deployed on heroku is to
# add the 'bonsai-elasticsearch-rails' gem, and include this Searchable concern
# in the models you want to index.
#
# Does not support Elasticsearch version > 5
# TODO: Once the elasticsearch/rails gems make it easier to use version 6, make this
# Searchable concern compatible.
#
# You'll want to look at the SearchIndexManager class next for information on how to customize
# the elasticsearch indices for your models.
#
# Once your model is configured, import documents with the rake task:
# `bin/rails forest:elasticsearch:rebuild`

begin
  require 'elasticsearch/model'
  require 'elasticsearch/rails'
rescue LoadError
end

module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    if Elasticsearch::Rails::VERSION.to_i < 6
      index_name SearchIndexManager::INDEX_NAME
    else
      index_name "#{SearchIndexManager::INDEX_NAME}_#{model_name.plural}"
    end

    # TODO: as an improvement implement Asynchronous Callbacks
    # https://github.com/elastic/elasticsearch-rails/tree/master/elasticsearch-model#asynchronous-callbacks

    after_commit on: [:create] do
      begin
        index_elasticsearch_document if indexable_for_elasticsearch?
      rescue Exception => e
        logger.warn { "[Forest][Searchable] Failed to index document #{self.class} #{self.id} #{e.inspect}" }
      end
    end

    after_commit on: [:update] do
      begin
        if indexable_for_elasticsearch?
          index_elasticsearch_document
        else
          delete_elasticsearch_document
        end
      rescue Exception => e
        logger.warn { "[Forest][Searchable] Failed to index document #{self.class} #{self.id} #{e.inspect}" }
      end
    end

    after_commit on: [:destroy] do
      begin
        delete_elasticsearch_document
      rescue Exception => e
        logger.warn { "[Forest][Searchable] Failed to delete document #{self.class} #{self.id} #{e.inspect}" }
      end
    end
  end

  class_methods do
    def searchable?
      true
    end

    # Override this in your host app with the scope method to use when importing elasticsearch documents. This
    # should probably match the conditions of the indexable_for_elasticsearch? method.
    def elasticsearch_import_model_scope
      if respond_to?(:statusable?)
        :published
      end
    end

    def elasticsearch(query)
      __elasticsearch__.search(query)
    end

    def non_indexed_attributes
      %W(id slug path status scheduled_date created_at updated_at featured_image_id parent_page_id redirect)
    end

    def indexed_attributes
      columns.select { |c| %i(text string).include?(c.type) }
             .collect(&:name)
             .reject { |c| c =~ /_url$/ } - non_indexed_attributes
    end

    def indexed_associations
      if self.try(:blockable?)
        {
          block_slots: {
            only: :block,
            include: {
              block: {
                methods: [:as_indexed_json],
                only: {
                  methods: [:as_indexed_json]
                }
              }
            }
          }
        }
      end
    end

    # def self.fields_to_search
    #   indexed_attributes.collect { |a|
    #     a =~ /name$/ ? "#{a}^2" : a
    #   }.concat(indexed_associations_to_search)
    # end

    # Override in your host app model to specify field search and match behavior
    def elasticsearch_query(query)
      {
        query: {
          match: {
            _all: sanitize_query(query)
          }
          # multi_match: {
          #   query: sanitize_query(query),
          #   fields: fields_to_search
          # }
        },
        highlight: {
          fields: { '*' => {} },
          require_field_match: false,
          pre_tags: ['|highlight|'],
          post_tags: ['|/highlight|']
        }
      }
    end

    def sanitize_query(query)
      return if query.blank?
      memo_key = "@_sanitize_query_#{query.parameterize.underscore}"
      return instance_variable_get(memo_key) if instance_variable_defined?(memo_key)
      instance_variable_set memo_key, begin
        # http://stackoverflow.com/a/16442439
        # Escape special characters
        # http://lucene.apache.org/core/old_versioned_docs/versions/2_9_1/queryparsersyntax.html#Escaping Special Characters
        escaped_characters = Regexp.escape('\\\/+-&|!(){}[]^~*?:')
        query = query.gsub(/([#{escaped_characters}])/, '\\\\\1')

        # AND, OR and NOT are used by lucene as logical operators. We need
        # to escape them
        ['AND', 'OR', 'NOT'].each do |word|
          escaped_word = word.split('').map {|char| "\\#{char}" }.join('')
          query = query.gsub(/\s*\b(#{word.upcase})\b\s*/, " #{escaped_word} ")
        end

        # Escape odd quotes
        quote_count = query.count '"'
        query = query.gsub(/(.*)"(.*)/, '\1\"\3') if quote_count % 2 == 1

        query
      end
    end
  end

  def searchable?
    true
  end

  # Override this method if you need to customize the logic that determines
  # if a record is published, or should be indexed for the public.
  def indexable_for_elasticsearch?
    if self.respond_to?(:statusable?)
      self.try(:published?)
    else
      true
    end
  end

  def non_indexed_attributes
    self.class.non_indexed_attributes
  end

  def indexed_attributes
    self.class.indexed_attributes
  end

  def indexed_associations
    self.class.indexed_associations
  end

  def as_indexed_json(options={})
    self.as_json({
      only: indexed_attributes,
      include: indexed_associations
    })
  end

  private

  def index_elasticsearch_document
    logger.debug { '[Forest][Searchable] Indexing document' }
    __elasticsearch__.index_document
  end

  def delete_elasticsearch_document
    logger.debug { '[Forest][Searchable] Deleting document' }
    __elasticsearch__.delete_document ignore: 404
  end
end
