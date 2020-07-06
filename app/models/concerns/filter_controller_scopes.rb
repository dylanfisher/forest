module FilterControllerScopes
  extend ActiveSupport::Concern

  # TODO: is this module even a good practice?
  included do
    has_scope :by_id
    has_scope :by_title
    has_scope :by_slug
    has_scope :by_created_at
    has_scope :by_updated_at
    has_scope :by_status
    has_scope :fuzzy_search
  end
end
