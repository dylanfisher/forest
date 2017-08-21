require 'csv'

module Forest
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

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

    private

      def self.valid_csv_column_types
        %i(integer text string boolean)
      end

      def self.invalid_csv_column_names
        %w(id created_at updated_at status slug)
      end
  end
end
