module Sluggable
  extend ActiveSupport::Concern

  included do
    # TODO: In some edge cases it seems like a record can be saved without generating a slug.
    # It may make sense to generate the slug in an after_commit hook in case that edge case happens.
    before_validation :generate_slug
    before_validation :parameterize_slug, if: :will_save_change_to_slug?

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
      raise Forest::Error.new("Slug attribute :title does not exist on #{self.class.name}. Define a `slug_attribute` method with a valid attribue, or have the method return false to generate a random slug.")
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

    existing_record = existing_record_with_slug(slug_attr)
    if existing_record.present? && existing_record != self
      self.slug = "#{slug_attr}#{duplicate_slug_identifier}"
    end
  end

  def existing_record_with_slug(slug_attr)
    self.class.find_by_slug(slug_attr)
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
