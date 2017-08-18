class BlockSlot < Forest::ApplicationRecord
  parent_class = self

  validates_presence_of :block_kind

  belongs_to :block, polymorphic: true, dependent: :destroy
  belongs_to :block_record, polymorphic: true
  belongs_to :block_kind
  belongs_to :block_layout

  accepts_nested_attributes_for :block, reject_if: :all_blank, allow_destroy: true

  scope :by_layout, -> (block_layout) { where(block_layout_id: block_layout.id) }

  # Merge these blockable params into the blockable record's strong params
  def self.blockable_params
    {
      block_slots_attributes: [
        :id, :_destroy, :position,
        :block_type, :block_record_type,
        :block_id, :block_kind_id, :block_layout_id, :block_record_id,
        block_attributes: [*BlockKind.block_kind_params]
      ]
    }
  end

  def block_attributes=(attributes)
    if BlockKind.all.collect(&:name).include?(self.block_kind.name)
      self.block ||= self.block_kind.name.constantize.new
      self.block.assign_attributes(attributes)
    end
  end

  protected

    def build_block(kind = nil)
      kind ||= self.block_kind.name.constantize
      self.block = kind.new
    end
end
