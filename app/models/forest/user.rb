module Forest
  class User < ApplicationRecord
    has_secure_password
    has_many :sessions, dependent: :destroy, inverse_of: :user, foreign_key: "forest_user_id"

    normalizes :email_address, with: ->(e) { e.strip.downcase }
  end
end
