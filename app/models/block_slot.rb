class BlockSlot < Forest::ApplicationRecord
  parent_class = self

  validates_presence_of :block_kind

  belongs_to :block, polymorphic: true, dependent: :destroy
  belongs_to :block_record, polymorphic: true
  belongs_to :block_kind

  accepts_nested_attributes_for :block, reject_if: :all_blank, allow_destroy: true

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
