module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug

    validates :slug, presence: true, uniqueness: true

    scope :by_slug, -> (orderer = :asc) { order(slug: orderer) }

    # Override this method to define which attribute the slug is created from
    def slug_attribute
      title
    end

    def generate_slug
      self.slug = slug_attribute.parameterize if generate_slug?
    end

    def generate_slug?
      self.slug.blank? || changed.include?('slug')
    end

    def to_friendly_param
      slug
    end
  end
end
