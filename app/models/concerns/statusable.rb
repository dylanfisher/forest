module Statusable
  extend ActiveSupport::Concern

  included do
    parent_class = self

    enum status: {
      published: 1,
      # draft: 2,
      scheduled: 3,
      # pending: 4,
      hidden: 5
    }

    validates_presence_of :status

    scope :by_status, -> (status) { where(status: status) }
    scope :published_or_scheduled, -> {
      where("#{parent_class.model_name.plural}.status = :published OR (#{parent_class.model_name.plural}.status = :scheduled AND COALESCE(#{parent_class.model_name.plural}.scheduled_date, :date_yesterday) <= :date_today)",
        published: 1,
        scheduled: 3,
        date_today: Date.today,
        date_yesterday: Date.yesterday)
    }

    def self.statusable?
      true
    end

    def statusable?
      true
    end
  end
end
