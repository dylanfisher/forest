class BlockSlot < Forest::ApplicationRecord
  parent_class = self

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

    def build_block
      self.block = self.block_kind.name.constantize.new
    end
end
