# Add the ability to generate paths for hierarchical records. For example, categories
# that can have any number of associated sub-categories, or pages that have parent pages.
#
# Your model should have the following attributes:
#   path:text
#   slug:string (with a unique index)
#   parent_#{model_name.singular} (e.g. parent_page)
#
# You are expected to include the Sluggable concern, and it must be included *before* Pathable.
module Pathable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_path, if: :hierarchy_changed?
    after_save :generate_descendent_paths, if: :hierarchy_changed?

    validates :path, presence: true, uniqueness: true
    validate :parent_record_is_not_self_or_ancestor

    has_many :immediate_children, class_name: model_name, foreign_key: "parent_#{model_name.singular}_id"
  end

  def to_friendly_param
    path
  end

  def parent_association_name
    "parent_#{model_name.singular}"
  end

  def parent_association_id
    "parent_#{model_name.singular}_id"
  end

  def generate_path
    if record_ancestors.any?
      generated_path = "#{record_ancestors.reverse.collect(&:slug).join('/')}/#{slug}"
    else
      generated_path = slug
    end
    self.path = generated_path
  end

  def generate_descendent_paths
    record_descendents.each do |record_descendent|
      record_descendent.generate_path
      record_descendent.save
    end
  end

  def record_ancestors
    # Note: these recursive function aren't performant and should be cached in the view
    @_record_ancestors ||= begin
      ancestors ||= []
      record = self
      parent = record.try(parent_association_name) unless record.try(parent_association_name) == record
      while parent
        ancestors << parent
        record = parent
        parent = record.try(parent_association_name)
      end
      ancestors
    end
  end

  def record_descendents
    # Note: these recursive function aren't performant and should be cached in the view
    @_record_descendents ||= begin
      descendents = []
      children = immediate_children

      while children.present?
        descendents.concat children
        children = children.collect(&:immediate_children).reject(&:blank?).flatten
      end

      descendents
    end
  end

  def record_root
    @_record_root ||= record_ancestors.find { |r| r.send(parent_association_id).nil? }
  end

  def descendent_of?(record_or_record_slug)
    if record_or_record_slug.is_a?(self.class)
      record_ancestors.any? { |r| r == record_or_record_slug }
    else
      record_ancestors.any? { |r| r.slug == record_or_record_slug }
    end
  end

  def remove_record_hierarchy!
    immediate_children.update(parent_association_id => nil)
  end

  private

  def current_or_previous_changes
    changed.presence || previous_changes.keys
  end

  def hierarchy_changed?
    (current_or_previous_changes & [parent_association_id, 'slug']).any?
  end

  def parent_record_is_not_self_or_ancestor
    if send(parent_association_name) == self
      errors.add parent_association_name, "a parent #{model_name.singular} can't be assigned to itself."
    elsif record_ancestors.include?(self)
      errors.add parent_association_name, "a parent #{model_name.singular} can't be assigned to an ancestor of itself."
    end
  end
end
