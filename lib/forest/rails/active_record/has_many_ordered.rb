module Forest
  module HasManyOrdered
    extend ActiveSupport::Concern

    class_methods do
      def has_many_ordered(association, options = {})
        through = options.delete(:through)
        through_options = options.delete(:through_options) || {}
        has_many_options = options.delete(:has_many_options) || {}
        order_by = options.delete(:order_by) || :position
        singular = association.to_s.singularize
        singular_id = (has_many_options.fetch(:source, nil).try(:to_s).try(:singularize) || singular).to_s + '_id'

        has_many through, -> { reorder(order_by) }, options.reverse_merge(dependent: :destroy, **through_options)
        has_many association, -> { reorder("#{through}.#{order_by}") }, options.merge(through: through, **has_many_options)
        accepts_nested_attributes_for through, allow_destroy: true

        define_method("#{singular}_ids=") do |ids|
          ids = ids.reject(&:blank?).collect(&:to_i)
          super(ids)
          send(through).each do |join_model|
            join_model.send("#{order_by}=", ids.index(join_model.send(singular_id)))
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Forest::HasManyOrdered)
