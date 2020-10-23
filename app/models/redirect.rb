class Redirect < Forest::ApplicationRecord
  include Statusable

  validates :from_path, :to_path, presence: true

  def self.resource_description
    'Redirect from one place to another.'
  end
end
