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

    private

      def self.valid_csv_column_types
        %i(integer text string boolean)
      end

      def self.invalid_csv_column_names
        %w(id created_at updated_at status slug)
      end
  end
end
