module Blockable
  extend ActiveSupport::Concern

  included do
    parent_class = self

    has_many :block_slots, -> { order(:position) },
             as: :block_record,
             foreign_key: 'block_record_id',
             dependent: :destroy

    accepts_nested_attributes_for :block_slots, allow_destroy: true

    def self.blockable?
      true
    end

    def blockable?
      true
    end

    # TODO: rename block_slots to blocks and get rid of this method?
    def blocks(options = {})
      block_layout = options.fetch(:block_layout, BlockLayout.default_layout)
      block_type = options.fetch(:kind, nil)

      instance_variable_get("@#{block_layout.slug}_blocks") || instance_variable_set("@#{block_layout.slug}_blocks", begin
        if block_type
          b = block_slots.includes(:block).where(block_kind_id: block_type.kind.id)
        else
          b = block_slots.includes(:block, :block_layout)
        end
        b.select { |bs| bs.block_layout == block_layout }.collect(&:block)
      end)
    end

  end
end
