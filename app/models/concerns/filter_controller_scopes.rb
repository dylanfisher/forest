module FilterControllerScopes
  extend ActiveSupport::Concern

  included do
    has_scope :by_id
    has_scope :by_title
    has_scope :by_slug
    has_scope :by_created_at
    has_scope :by_updated_at
    has_scope :by_status
    has_scope :search
  end
end
