module Searchable
  extend ActiveSupport::Concern

  included do
    scope :search, -> (query) {
      where(self.columns.select{ |x| [:string, :text].include?(x.type) }.map(&:name).collect{ |x|
        "#{self.model_name.plural}.#{x}" + ' ILIKE :query'
      }.join(' OR '), query: "%#{query}%")
    }
  end
end
