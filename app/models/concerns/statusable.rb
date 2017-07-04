module Statusable
  extend ActiveSupport::Concern

  included do
    enum status: {
        published: 1,
        draft: 2,
        scheduled: 3,
        pending: 4,
        hidden: 5
      }
  end
end
