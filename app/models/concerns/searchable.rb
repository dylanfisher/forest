# This module provides a search interface to the record using elasticsearch-rails.
# The easiest way to implement search in your host app deployed on heroku is to
# add the 'bonsai-elasticsearch-rails' gem, and include this Searchable concern
# in the models you want to index.
#
# Does not support Elasticsearch version > 6
# TODO: Once the elasticsearch/rails gems make it easier to use version 6, make this
# Searchable concern compatible.
#
# You'll want to look at the SearchIndexManager class next for information on how to customize
# the elasticsearch indices for your models.

begin
  require 'elasticsearch/model'
  require 'elasticsearch/rails'
rescue LoadError
end

module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    index_name SearchIndexManager::INDEX_NAME

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

    def self.searchable?
      true
    end

    def self.elasticsearch(query)
      __elasticsearch__.search(query)
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
      %W(id slug path status scheduled_date created_at updated_at featured_image_id parent_page_id)
    end

    def indexed_attributes
      self.class.column_names - non_indexed_attributes
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

    def as_indexed_json(options={})
      self.as_json({
        only: indexed_attributes,
        include: indexed_associations
      })
    end
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
