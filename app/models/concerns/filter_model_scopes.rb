module FilterModelScopes
  extend ActiveSupport::Concern

  included do
    scope :by_id, -> (orderer = :desc) { order(id: orderer) }
    scope :by_title, -> (orderer = :asc) { order(title: orderer) }
    scope :by_slug, -> (orderer = :asc) { order(slug: orderer) }
    scope :by_created_at, -> (orderer = :desc) { order(created_at: orderer) }
    scope :by_updated_at, -> (orderer = :desc) { order(updated_at: orderer) }
    scope :by_status, -> (status) { where(status: status) }
  end
end
