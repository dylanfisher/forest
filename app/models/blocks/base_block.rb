class BaseBlock < Forest::ApplicationRecord
  self.abstract_class = true

  has_one :block_slot,
          as: :block,
          inverse_of: :block,
          class_name: 'BlockSlot',
          dependent: :destroy

  # Override to customize the display name of the block.
  def self.display_name
    'Base Block'
  end

  # Override to change the method of determining the display icon for the block. The default display method is Bootstrap 4's icon system
  def self.display_icon
    path = Rails.env.development? ? ActionController::Base.helpers.asset_path('bootstrap-icons.svg') : '/public/bootstrap-icons.svg'
    "<svg class='bi' style='width: 1.3em; height: 1.3em;' fill='currentColor'><use xlink:href='#{path}##{display_icon_name}'/></svg>".html_safe
  end

  # Override to add a Bootstrap 4 icon next to the block's title.
  # https://icons.getbootstrap.com/
  def self.display_icon_name
    'square'
  end

  def self.kind
    BlockKind.find_by_name(name)
  end

  def self.description
    nil
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

  # Override to add css classes to a block's wrapper.
  def css_class
  end

  # Override to add css styles to a block's wrapper.
  def css_styles
  end

  # Override to add data attributes to a block's wrapper. Make sure this is a hash.
  def data_attributes
  end

  def display_icon
    self.class.display_icon
  end

  def display_icon_name
    self.class.display_icon_name
  end

  def permitted_params
    self.class.permitted_params
  end

  def block_id
    "#{self.model_name.singular.dasherize}-#{self.id}"
  end

  def block_kind
    @block_kind ||= BlockKind.find_by_name(self.class.name)
  end

  def block_record
    @block_record ||= block_slot.block_record
  end

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
    index == blocks.length - 1
  end

  def first_of_kind?
    blocks.first_of_kind(self.class) == self
  end

  def last_of_kind?
    blocks.last_of_kind(self.class) == self
  end

  def index_of_kind
    blocks.kind(self.class).index(self)
  end

  def even_of_kind?
    index_of_kind.even?
  end

  def odd_of_kind?
    index_of_kind.odd?
  end

  def previous
    return nil if first?
    blocks[index - 1]
  end

  def next
    return nil if last?
    blocks[index + 1]
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
