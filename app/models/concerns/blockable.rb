module Blockable
  extend ActiveSupport::Concern

  included do
    parent_class = self

    after_destroy :destroy_associated_blocks

    # has_many :block_layouts

    has_many :block_slots, -> { where(block_record_type: parent_class.name).order(:position) },
             foreign_key: 'block_record_id',
             dependent: :destroy

    accepts_nested_attributes_for :block_slots, allow_destroy: true

    # TODO: rename block_slots to blocks and get rid of this method?
    def blocks(options = {})
      block_layout = options.fetch(:block_layout, BlockLayout.default_layout)

      instance_variable_get("@#{block_layout.slug}_blocks") || instance_variable_set("@#{block_layout.slug}_blocks", begin
        block_slots.includes(:block).select { |bs| bs.block_layout == block_layout }.collect(&:block)
      end)
    end

    private

      def destroy_associated_blocks
        block_slots.destroy_all
      end
  end
end
