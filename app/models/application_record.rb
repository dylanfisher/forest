class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Add the following code to your app's ApplicationRecord to update the application wide cache key.
  after_commit :expire_application_cache_key

  private

  def expire_application_cache_key
    Setting.expire_application_cache_key!
  end
end
