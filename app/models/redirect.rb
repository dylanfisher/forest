class Redirect < Forest::ApplicationRecord
  include Statusable

  validates :from_path, :to_path, presence: true

  def self.resource_description
    'Forward a request for a URL at your website to another URL.'
  end
end
