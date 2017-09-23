module Forest
  module HasRepeatable
    extend ActiveSupport::Concern

    class_methods do
      def has_repeatable(attribute, options = {})
        serialize attribute, Array

        before_save :"remove_blank_#{attribute}"

        define_method(:"remove_blank_#{attribute}") do
          self.send(attribute).reject! { |a| a[:key].blank? && a[:value].blank? }
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Forest::HasRepeatable)
