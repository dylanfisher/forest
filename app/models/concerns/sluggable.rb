module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug
    before_save :parameterize_slug, if: :will_save_change_to_slug?

    # validates :slug, presence: true, uniqueness: true

    scope :by_slug, -> (orderer = :asc) { order(slug: orderer) }

    def self.sluggable?
      true
    end

    def sluggable?
      true
    end

    # Override this method to define which attribute the slug is created from, or
    # have this method return false to use a random slug
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
      return unless generate_slug?

      if slug_attribute.present?
        slug_attr = slug_attribute.parameterize
        if slug_as_key?
          slug_attr = slug_attribute.parameterize.underscore
        end
      else
        slug_attr = SecureRandom.uuid
      end

      self.slug = slug_attr

      if self.class.find_by_slug(slug_attr).present?
        self.slug = "#{slug_attr}-#{SecureRandom.uuid}"
      end
    end

    def generate_slug?
      self.slug.blank?
    end

    # Override slug_as_key? in models like settings where the slug should be underscored, not dasherized
    def slug_as_key?
      false
    end

    def to_friendly_param
      slug
    end

    private

      def parameterize_slug
        self.slug = slug.parameterize
      end
  end
end
