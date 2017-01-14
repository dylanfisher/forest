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

  def self.collection_for_picker
    self.all
  end

  def display_name
    self.name.constantize.display_name
  end

  def display_icon
    self.name.constantize.display_icon
  end
end
