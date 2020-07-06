module Cloneable
  extend ActiveSupport::Concern

  def cloneable_associations
    if blockable?
      { include: [ block_slots: :block ] }
    else
      {}
    end
  end

  def clone_record!
    # If a record is sluggable?, you may need to pass validate: false to the deep_clone method.
    # It may be worthwhile to update this to be a little smarter in terms of validating and
    # revalidating automatically, potentially with the progress from this commit:
    # https://github.com/dylanfisher/forest/blob/7da11c99a4cdc5535745a837a4d5654a9796a39d/app/models/concerns/versionable.rb

    # new_record = deep_clone(**cloneable_associations, validate: false)
    new_record = deep_clone(**cloneable_associations)
    new_record.slug = nil if new_record.respond_to?(:slug)
    new_record.attributes.keys.each { |k, _| new_record.send("#{k}_will_change!") }
    new_record.save!
    new_record
  end
end
