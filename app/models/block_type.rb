class BlockType < ApplicationRecord
  def self.block_type_params
    self.all.collect do |block_type|
      {
        block_fields: {
          block_type.name => block_type.name.constantize.permitted_params
        }
      }
    end
  end
end
