require 'csv'

module Forest
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    after_commit :expire_application_cache_key, if: :expire_application_cache_key?
    after_commit :expire_cache_key, if: :expire_cache_key?

    scope :by_id, -> (orderer = :desc) {
      orderer = %i(asc desc).include?(orderer.to_sym) ? orderer : :desc
      order(id: orderer)
    }
    scope :by_title, -> (orderer = :asc) {
      orderer = %i(asc desc).include?(orderer.to_sym) ? orderer : :desc
      order(title: orderer, id: :desc)
    }
    scope :by_created_at, -> (orderer = :desc) {
      orderer = %i(asc desc).include?(orderer.to_sym) ? orderer : :desc
      order(created_at: orderer,
            id: orderer)
    }
    scope :by_updated_at, -> (orderer = :desc) {
      orderer = %i(asc desc).include?(orderer.to_sym) ? orderer : :desc
      order(updated_at: orderer,
            id: orderer)
    }
    scope :fuzzy_search, -> (query) {
      columns_to_search = self.columns
                              .select { |x| [:string, :text].include?(x.type) }
                              .map(&:name).collect { |x| "#{self.model_name.plural}.#{x} ILIKE :query" }
      columns_to_search << "CAST(#{self.model_name.plural}.id AS TEXT) ILIKE :query"
      where(columns_to_search.join(' OR '), query: "%#{sanitize_sql_like(query)}%")
    }

    def self.cache_key_name
      "forest_all_#{model_name.plural}_cache_key"
    end

    def self.cache_key
      Rails.cache.fetch self.cache_key_name, expires_in: 4.weeks do
        SecureRandom.uuid
      end
    end

    def self.csv_columns
      valid_columns = self.columns.select { |a| valid_csv_column_types.include?(a.type) }
      valid_columns.collect(&:name) - invalid_csv_column_names
    end

    def self.to_csv_template
      CSV.generate(headers: true) do |csv|
        csv << csv_columns
      end
    end

    # Statusable default
    def self.statusable?
      false
    end

    def statusable?
      false
    end

    def self.expire_cache_key
      Rails.cache.delete cache_key_name
    end

    def expire_cache_key
      self.class.expire_cache_key
    end

    # Override this to define a friendly param attribute, like `slug` or `path`
    def to_friendly_param
      to_param
    end

    def to_label
      if try(:display_name).present?
        display_name
      elsif try(:name).present?
        name
      elsif try(:title).present?
        title
      else
        "#{self.model_name.human} #{id}"
      end
    end

    def to_select2_response
      if respond_to?(:media_item) && media_item.try(:attachment_url, :thumb).present?
        img_tag = "<img src='#{media_item.attachment_url(:thumb)}' style='height: 21px; margin-right: 5px;'> "
      elsif respond_to?(:featured_media_item) && featured_media_item.try(:attachment_url, :thumb).present?
        img_tag = "<img src='#{featured_media_item.attachment_url(:thumb)}' style='height: 21px; margin-right: 5px;'> "
      end
      status = ApplicationController.helpers.status_indicator(self, class: 'select2-response__status') if self.try(:statusable?)
      "#{img_tag}<span class='select2-response__id' data-id='#{id}' style='margin-right: 5px;'>#{status}#{id}</span> #{to_label.gsub(/<br\s*\/?>/, ' ')}"
    end

    def to_select2_selection
      to_select2_response
    end

    private

    def self.valid_csv_column_types
      %i(integer text string boolean)
    end

    def self.invalid_csv_column_names
      %w(id created_at updated_at status slug)
    end

    def expire_application_cache_key
      Setting.expire_application_cache_key!
    end

    # Override in your host app models that don't need to bust the entire application's cache key
    def expire_application_cache_key?
      true
    end

    # Override in your host app models that don't need to bust this model's cache key
    def expire_cache_key?
      true
    end
  end
end
