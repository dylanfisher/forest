module Forest
  class Session < ApplicationRecord
    belongs_to :user, class_name: "Forest::User", foreign_key: "forest_user_id"
  end
end
