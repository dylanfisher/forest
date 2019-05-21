class BlockSlot < Forest::ApplicationRecord
  parent_class = self

  validates_presence_of :block_kind
  validates :block_record, presence: true, on: :update

  belongs_to :block, polymorphic: true, dependent: :destroy
  belongs_to :block_record, polymorphic: true #, optional: true
  belongs_to :block_kind, inverse_of: :block_slots
  belongs_to :block_layout, inverse_of: :block_slots

  before_validation :create_block_if_block_attributes_empty

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
    if BlockKind.where(name: self.block_kind.name).exists?
      self.block ||= self.block_kind.name.constantize.new
      self.block.assign_attributes(attributes)
    end
  end

  def create_block_if_block_attributes_empty
    if BlockKind.where(name: self.block_kind.name).exists? && BlockKind.where(name: self.block_kind.name).first.block.permitted_params.blank?
      self.block ||= self.block_kind.name.constantize.new
    end
  end

  protected

    def build_block(kind = nil)
      kind ||= self.block_kind.name.constantize
      self.block = kind.new
    end
end
