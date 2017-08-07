module Statusable
  extend ActiveSupport::Concern

  PUBLISHED = 'published'

  included do
    enum status: {
        published: 1,
        draft: 2,
        scheduled: 3,
        pending: 4,
        hidden: 5
      }

    def self.statusable?
      true
    end

    def statusable?
      true
    end
  end
end
