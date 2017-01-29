class UserGroup < ApplicationRecord
  include Searchable
  include FilterModelScopes

  has_and_belongs_to_many :users

  scope :by_name, -> (orderer = :asc) { order(name: orderer) }

  def to_label
    name.titleize
  end
end
