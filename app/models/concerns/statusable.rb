module Statusable
  extend ActiveSupport::Concern

  included do
    enum status: {
        published: 1,
        # draft: 2,
        # scheduled: 3,
        # pending: 4,
        hidden: 5
      }

    validates_presence_of :status

    scope :by_status, -> (status) { where(status: status) }

    def self.statusable?
      true
    end

    def statusable?
      true
    end
  end
end
