module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug
    before_save :parameterize_slug, if: :will_save_change_to_slug?

    # validates :slug, presence: true, uniqueness: true

    scope :by_slug, -> (orderer = :asc) { order(slug: orderer) }
  end

  class_methods do
    def sluggable?
      true
    end
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

    existing_record_with_slug = self.class.find_by_slug(slug_attr)
    if existing_record_with_slug.present? && existing_record_with_slug != self
      self.slug = "#{slug_attr}#{duplicate_slug_identifier}"
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

  def duplicate_slug_identifier
    "-#{SecureRandom.uuid}"
  end

  private

    def parameterize_slug
      self.slug = slug.parameterize
    end
end
