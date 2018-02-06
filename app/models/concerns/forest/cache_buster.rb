# Include the CacheBuster concern in a model to automatically update
# all of a model's associated records (hopefully).
#
# There are only two hard things in Computer Science: cache invalidation and naming things.
# -- Phil Karlton

module Forest::CacheBuster
  extend ActiveSupport::Concern

  included do
    after_save :touch_associations
    after_save :touch_dependent_records

    # A cached set of associations is stored in a polymorphic record after every save.
    # This allows us to know what the previous set of associated records was during a
    # record's after_save callback, which is important when associations are removed.
    has_one :cache_record, as: :cacheable, dependent: :destroy

    private

      def touch_associations
        # Find all relevant associations
        has_many_associations = self.class.reflect_on_all_associations(:has_many)
        habtm_many_associations = self.class.reflect_on_all_associations(:has_and_belongs_to_many)
        all_associations = has_many_associations + habtm_many_associations

        # Collect a set of associated records (ActiveRecord::Associations objects)
        association_groups = all_associations.collect { |association| self.send(association.plural_name) }

        to_update = {}
        time_now = Time.now

        # Find the cache_record or build a new one
        cache_record = cache_record.presence || self.build_cache_record

        # Extract the associated class name and ids from the cache_record
        if cache_record.data.present?
          cache_record.data.each do |cache_record_item|
            klass = cache_record_item['klass']
            id = cache_record_item['id']
            to_update[klass] ||= []
            to_update[klass] << id
          end
        end

        # Update the associations currently attached to the record
        association_groups.each do |records|
          if records.try :any?
            if records.class.parent.name == 'ActiveRecord::Associations'
              logger.debug { "[Forest] CacheBuster is updating associations for #{records.length} #{records.first.class.model_name.plural}" }
              records.unscope(:order).update_all updated_at: time_now

              # Delete record ids from the to_update hash if we update them here
              records.to_a.flatten.each do |record|
                to_update[record.class.name] ||= []
                to_update[record.class.name].delete(record.id)
              end
            end
          end
        end

        # Update any remaining associations
        to_update.each do |klass, ids|
          records = klass.safe_constantize&.where(id: ids)
          if records.present?
            logger.debug { "[Forest] CacheBuster is updating remaining associations for #{records.length} #{records.first.class.model_name.plural} inferred from the cache_record" }
            records.unscope(:order).update_all(updated_at: time_now)
          end
        end

        # Store the new set of associations in the cache_record
        cache_record.data = association_groups.flatten.collect do |record|
          { klass: record.class.name, id: record.id }
        end

        # Save the cache_record
        cache_record.save
      end

      # In some situations a block might rely on data that isn't associated via an ActiveRecord
      # Association. For example, a CurrentExhibitions block depends on Exhibition, but doesn't rely
      # on an association. In that case, override this method in the model and bust the associated data
      # as necessary, using something like the commented out code here.
      def touch_dependent_records
        # For example:
        # 'CurrentExhibitionsBlock'.safe_constantize&.update_all(updated_at: Time.now)
      end
  end
end
