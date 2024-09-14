module Statusable
  extend ActiveSupport::Concern

  # To make a record schedulable, create a date column named published_date
  # TODO: remove references to scheduled_date in favor of published_date

  included do
    parent_class = self

    enum :status, {
      published: 1,
      # draft: 2,
      scheduled: 3,
      # pending: 4,
      hidden: 5
    }

    validates_presence_of :status

    before_save :set_status_by_published_date

    scope :by_status, -> (status) { where(status: status) }
    scope :published_or_scheduled, -> {
      where("#{parent_class.model_name.plural}.status = :published OR (#{parent_class.model_name.plural}.status = :scheduled AND COALESCE(#{parent_class.model_name.plural}.#{attribute_for_scheduled_date}, :date_yesterday) <= :date_today)",
        published: 1,
        scheduled: 3,
        date_today: Date.today,
        date_yesterday: Date.yesterday)
    }
  end

  class_methods do
    def statusable?
      true
    end

    def statuses_for_select
      if (self.column_names & ['scheduled_date', 'published_date']).present?
        self.statuses
      else
        self.statuses.except(:scheduled)
      end
    end

    def attribute_for_scheduled_date
      if column_names.include?('scheduled_date')
        :scheduled_date
      elsif column_names.include?('published_date')
        :published_date
      end
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
      if self.send(self.class.attribute_for_scheduled_date).present? && self.send(self.class.attribute_for_scheduled_date).to_date <= Date.today
        self.status = self.scheduled? ? 'published' : self.status
      else
        self.status = self.published? ? 'published' : self.status
      end
    end
  end
end
