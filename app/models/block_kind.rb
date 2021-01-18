class BlockKind < Forest::ApplicationRecord
  has_many :block_slots, inverse_of: :block_kind

  scope :by_name, -> (orderer = :asc) { order(name: orderer, id: :desc) }

  # TODO: - set up a BlockKind has_many blocks association?
  #       - when destroying a BlockKind, also destroy all associated blocks?

  def self.block_kind_params
    self.all.collect do |block_kind|
      block_kind.block.permitted_params + [:id, :_destroy]
    end
  end

  def self.resource_description
    "A block kind represents the different types of blocks that may be used to add content to a page."
  end

  def block
    @block ||= self.name.constantize
  end

  def display_name
    block.display_name
  end

  def to_label
    display_name
  end

  def display_icon
    block.display_icon
  end

  def description
    block.description
  end

  def to_select2_response
    r = ''
    r << '<div>'
    r << "<span class='block-kind__select2-response__icon'>#{display_icon}</span> "
    r << '<strong>'
    r << display_name
    r << '</strong>'
    r << '</div>'

    if description.present?
      r << '<div class="text-muted">'
      r << '<smaller>'
      r << description
      r << '</smaller>'
      r << '</div>'
    end

    r
  end
end
