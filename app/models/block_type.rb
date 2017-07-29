class BlockType < Forest::ApplicationRecord
  scope :by_name, -> (orderer = :asc) { order(name: orderer, id: :desc) }

  def self.block_type_params
    self.all.collect do |block_type|
      {
        block_fields: {
          block_type.name => block_type.block.permitted_params
        }
      }
    end
  end

  def block
    @block ||= self.name.constantize
  end

  def display_name
    block.display_name
  end

  def display_icon
    block.display_icon
  end
end
