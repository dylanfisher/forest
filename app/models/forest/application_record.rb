require 'csv'

module Forest
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    scope :by_id, -> (orderer = :desc) { order(id: orderer) }
    scope :by_title, -> (orderer = :asc) { order(title: orderer, id: :desc) }
    scope :by_created_at, -> (orderer = :desc) { order(created_at: orderer, id: orderer) }
    scope :by_updated_at, -> (orderer = :desc) { order(updated_at: orderer, id: orderer) }
    scope :search, -> (query) {
      columns_to_search = self.columns
                              .select { |x| [:string, :text].include?(x.type) }
                              .map(&:name).collect { |x| "#{self.model_name.plural}.#{x} ILIKE :query" }
      columns_to_search << "CAST(#{self.model_name.plural}.id AS TEXT) ILIKE :query"
      where(columns_to_search.join(' OR '), query: "%#{query}%")
    }

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

    # Versionable default
    def self.versionable
      false
    end

    def versionable
      false
    end

    # Override this to define a friendly param attribute, like `slug` or `path`
    def to_friendly_param
      to_param
    end

    def to_label
      if respond_to?(:display_name)
        display_name
      elsif respond_to?(:name)
        name
      elsif respond_to?(:title)
        title
      else
        "#{self.model_name.human} #{id}"
      end
    end

    def to_select2_response
      "<span class='select2-response__id'>#{id}</span> #{to_label}"
    end

    private

      def self.valid_csv_column_types
        %i(integer text string boolean)
      end

      def self.invalid_csv_column_names
        %w(id created_at updated_at status slug)
      end
  end
end
