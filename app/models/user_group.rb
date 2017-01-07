class UserGroup < ApplicationRecord
  has_and_belongs_to_many :users

  def to_label
    name.titleize
  end
end
