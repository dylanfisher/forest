class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Add the following code to your app's ApplicationRecord to update the application
  # wide cache key.
  after_commit :bust_application_cache_key

  private

  def bust_application_cache_key
    Rails.application.config.forest_application_cache_key = SecureRandom.uuid
  end
end
