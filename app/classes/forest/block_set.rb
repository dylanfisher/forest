class Forest::BlockSet
  delegate_missing_to :@blocks

  def initialize(blocks = [], options = {})
    @blocks = blocks
  end

  def kind(block_kinds)
    @kind ||= {}
    block_kinds = Array(block_kinds).collect(&:to_s)
    @kind[block_kinds] ||= block_kinds
    @blocks.select do |block|
      @kind[block_kinds].select do |block_kind|
        @kind[block_kinds].include?(block.class.name)
      end.present?
    end
  end

  def except(block_kinds)
    block_kinds = Array(block_kinds).collect(&:to_s)
    @blocks.reject do |block|
      block_kinds.include?(block.class.name)
    end
  end

  def first_of_kind(block_kind)
    kind(block_kind).first
  end

  def last_of_kind(block_kind)
    kind(block_kind).last
  end
end
