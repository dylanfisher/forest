class BaseBlock < Forest::ApplicationRecord
  self.abstract_class = true

  has_one :block_slot, class_name: 'BlockSlot', as: :block, dependent: :destroy

  def self.display_name
    'Base Block'
  end

  def self.display_icon
    'glyphicon glyphicon-tree-conifer'
  end

  def self.kind
    BlockKind.find_by_name(name)
  end

  def display_name
    self.class.display_name
  end

  def hidden?
    false
  end

  def block?
    true
  end

  def display_icon
    self.class.display_icon
  end

  def permitted_params
    self.class.permitted_params
  end

  def block_id
    "#{self.model_name.singular.dasherize}-#{self.id}"
  end

  # TODO: association to represent this?
  def block_record
    @block_record ||= block_slot.block_record
  end

  # TODO: association to represent this?
  def block_record_id
    block_record.block_record.id
  end

  def block_layout
    block_slot.block_layout
  end

  def blocks
    block_record.blocks(block_layout: block_layout)
  end

  def index
    blocks.index(self)
  end

  def first?
    index == 0
  end

  def last?
    index == block_record.blocks(block_layout: block_layout).length - 1
  end

  def non_indexed_attributes
    %W(id created_at updated_at)
  end

  # Override this in your block to define which attributes should be indexed for search
  def indexed_attributes
    self.class.columns.select { |c| %i(text string).include?(c.type) }
           .collect(&:name)
           .reject { |c| c =~ /_url$/ } - non_indexed_attributes
  end

  def as_indexed_json(options={})
    self.as_json({
      only: indexed_attributes
    })
  end
end
