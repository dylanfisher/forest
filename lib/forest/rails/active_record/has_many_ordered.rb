module Forest
  module HasManyOrdered
    extend ActiveSupport::Concern

    class_methods do
      def has_many_ordered(association, options = {})
        through = options.delete(:through)
        order_by = options.delete(:order_by) || :position
        singular = options.fetch(:source, association.to_s.singularize).to_s

        has_many through, -> { reorder(order_by) }, options.reverse_merge(dependent: :destroy)
        has_many association, -> { reorder("#{through}.#{order_by}") }, options.merge(through: through)
        accepts_nested_attributes_for through, allow_destroy: true

        define_method("#{singular}_ids=") do |ids|
          ids = ids.reject(&:blank?).collect(&:to_i)
          super(ids)
          send(through).each do |join_model|
            join_model.send("#{order_by}=", ids.index(join_model.send("#{singular}_id")))
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Forest::HasManyOrdered)
