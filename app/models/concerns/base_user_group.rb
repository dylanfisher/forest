module BaseUserGroup
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :users

    scope :by_name, -> (orderer = :asc) { order(name: orderer) }
  end

  class_methods do
    def resource_description
      "User groups allow you to control which users have access to certain resources."
    end
  end

  def display_name
    name.titleize
  end

  def to_label
    display_name
  end
end
