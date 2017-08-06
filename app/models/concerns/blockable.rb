module Blockable
  extend ActiveSupport::Concern

  included do
    parent_class = self

    after_destroy :destroy_associated_blocks

    has_many :block_slots, -> { where(block_record_type: parent_class.name).order(:position) }, foreign_key: 'block_record_id'
    # has_one :block_record, as: :block_record, dependent: :destroy

    accepts_nested_attributes_for :block_slots, allow_destroy: true

    # TODO: DF 08/04/17 - under some condition if a block is saved without a block_id, the record will crash

    # TODO: rename block_slots to blocks and get rid of this method?
    def blocks(options = {})
      layout = options.fetch(:layout, nil)

      @_blocks ||= begin
        if version.present?
          block_versions.where(block_record_version_id: version.id)
                        .reject(&:blank?)
                        .collect { |b| b.reify }
        else
          block_slots.includes(:block)
        end
      end

      if layout.present?
        @_blocks.select { |bs| bs.layout == layout.to_s }.collect(&:block)
      else
        @_blocks.collect(&:block)
      end
    end

    # TODO: make this more performant and/or not as weird
    def reify_block_slots!
      # self.block_slots = version.block_slots.collect { |bs|
      #   self.block_slots.build(bs.except('id', 'created_at', 'updated_at'))
      # }
    end

    private

      def destroy_associated_blocks
        block_slots.includes(:block).each { |block_slot| block_slot.block.destroy }
        block_slots.destroy_all
      end
  end
end
