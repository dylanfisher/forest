module Forest
  class Session < ApplicationRecord
    belongs_to :user, class_name: "Forest::User"
  end
end
