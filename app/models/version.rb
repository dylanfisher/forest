class Version < Forest::ApplicationRecord
  belongs_to :record, polymorphic: true

  # def self.resource_description
  #   "Briefly describe this resource."
  # end
end
