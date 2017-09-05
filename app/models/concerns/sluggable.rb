module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug

    # validates :slug, presence: true, uniqueness: true

    scope :by_slug, -> (orderer = :asc) { order(slug: orderer) }

    # Override this method to define which attribute the slug is created from
    def slug_attribute
      if respond_to?(:title)
        title
      elsif respond_to?(:name)
        name
      else
        raise Forest::Error.new("Slug attribute :title does not exist on #{self.class.name}. Define a `slug_attribute` method with a valid attribue.")
      end
    end

    def generate_slug
      if slug_attribute.present?
        slug_attr = slug_attribute.parameterize
      else
        slug_attr = SecureRandom.uuid
      end
      self.slug = slug_attr if generate_slug?
    end

    def generate_slug?
      self.slug.blank? || changed.include?('slug')
    end

    def to_friendly_param
      slug
    end
  end
end
