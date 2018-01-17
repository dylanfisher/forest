module Statusable
  extend ActiveSupport::Concern

  # To make a record schedulable, create a date column named scheduled_date

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

    before_save :check_active_scheduled_date

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

    def self.statuses_for_select
      if self.column_names.include?('scheduled_date')
        self.statuses
      else
        self.statuses.except(:scheduled)
      end
    end

    def statusable?
      true
    end

    private

      def check_active_scheduled_date
        if self.respond_to?(:scheduled_date)
          if self.scheduled_date.present? && self.scheduled_date <= Date.today
            self.status = 'published'
          end
        end
      end
  end
end
