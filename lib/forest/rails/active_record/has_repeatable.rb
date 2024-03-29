# https://github.com/dylanfisher/forest/wiki/SimpleForm-inputs-&-components#repeater_inputrb

module Forest
  module HasRepeatable
    extend ActiveSupport::Concern

    class_methods do
      def has_repeatable(attribute, options = {})
        serialize attribute, type: Array

        before_validation :"remove_blank_#{attribute}"

        define_method(:"remove_blank_#{attribute}") do
          if self.send(attribute).blank? || self.send(attribute).all? { |a| a[:key].blank? && a[:value].blank? }
            self.send "#{attribute}=", []
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Forest::HasRepeatable)
