module Versionable
  extend ActiveSupport::Concern

  included do
    has_many :versions, as: :record

    after_commit :create_new_version, on: [:create, :update]

    def self.versionable?
      true
    end

    def versionable?
      true
    end

    def cloneable_associations
      if blockable?
        { include: [ block_slots: :block ] }
      else
        {}
      end
    end

    def create_new_version
      self.class.skip_callback(:commit, :after, :create_new_version)

      random_hex = SecureRandom.hex

      new_record = deep_clone(**cloneable_associations, validate: false)

      new_record.slug = random_hex if new_record.respond_to?(:slug)
      new_record.path = random_hex if new_record.respond_to?(:path)

      new_version = Version.new
      new_version.record = new_record
      # new_record.record_id = self.id

      new_version.save!

      self.class.set_callback(:commit, :after, :create_new_version)

      true
    end
  end
end
