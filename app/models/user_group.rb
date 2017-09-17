class UserGroup < Forest::ApplicationRecord
  has_and_belongs_to_many :users

  scope :by_name, -> (orderer = :asc) { order(name: orderer) }

  def display_name
    name.titleize
  end

  def to_label
    display_name
  end
end
