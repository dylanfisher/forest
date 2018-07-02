module Statusable
  extend ActiveSupport::Concern

  # To make a record schedulable, create a date column named published_date
  # TODO: remove references to scheduled_date in favor of published_date

  included do
    parent_class = self

    enum status: {
      published: 1,
      # draft: 2,
      scheduled: 3,
      # pending: 4,
      hidden: 5,
      preview: 6
    }

    validates_presence_of :status

    before_save :set_status_by_published_date

    scope :by_status, -> (status) {
      if status.present?
        where(status: status)
      else
        where.not(status: 'preview')
      end
    }
    scope :published, -> { by_status(:published) }
    scope :published_or_scheduled, -> {
      where("#{parent_class.model_name.plural}.status = :published OR (#{parent_class.model_name.plural}.status = :scheduled AND COALESCE(#{parent_class.model_name.plural}.#{attribute_for_scheduled_date}, :date_yesterday) <= :date_today)",
        published: 1,
        scheduled: 3,
        date_today: Date.today,
        date_yesterday: Date.yesterday)
    }

    def self.statusable?
      true
    end

    def self.statuses_for_select
      if (self.column_names & ['scheduled_date', 'published_date']).present?
        self.statuses
      else
        self.statuses.except(:scheduled)
      end
    end

    def self.attribute_for_scheduled_date
      if column_names.include?('scheduled_date')
        :scheduled_date
      elsif column_names.include?('published_date')
        :published_date
      end
    end

    def statusable?
      true
    end

    private

      def set_status_by_published_date
        return if self.class.attribute_for_scheduled_date.blank?
        return if self.send(self.class.attribute_for_scheduled_date).blank?

        if self.respond_to?(self.class.attribute_for_scheduled_date)
          if self.send(self.class.attribute_for_scheduled_date).present? && self.send(self.class.attribute_for_scheduled_date) <= Date.today
            self.status = self.scheduled? ? 'published' : self.status
          else
            self.status = self.published? ? 'scheduled' : self.status
          end
        end
      end
  end
end
