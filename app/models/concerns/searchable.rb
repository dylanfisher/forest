# This module provides a search interface to the record using elasticsearch-rails.
# The easiest way to implement search in your host app deployed on heroku is to
# add the 'bonsai-elasticsearch-rails' gem, and include this Searchable concern
# in the models you want to index.

require 'elasticsearch/model'
require 'elasticsearch/rails'

module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # TODO: as an improvement implement Asynchronous Callbacks
    # https://github.com/elastic/elasticsearch-rails/tree/master/elasticsearch-model#asynchronous-callbacks

    after_commit on: [:create] do
      __elasticsearch__.index_document if indexable_for_elasticsearch?
    end

    after_commit on: [:update] do
      __elasticsearch__.index_document if indexable_for_elasticsearch?
    end

    after_commit on: [:destroy] do
      __elasticsearch__.delete_document ignore: 404 if indexable_for_elasticsearch?
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
      [:id, :slug, :path, :status, :scheduled_date, :created_at, :updated_at, :featured_image_id, :parent_page_id]
    end

    def indexed_associations
      if self.try(:blockable?)
        {
          block_slots: {
            only: :block,
            include: {
              block: {
                except: [:id, :created_at, :updated_at]
              }
            }
          }
        }
      end
    end

    def as_indexed_json(options={})
      self.as_json({
        except: non_indexed_attributes,
        include: indexed_associations
      })
    end
  end
end
