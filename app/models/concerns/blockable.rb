module Blockable
  extend ActiveSupport::Concern

  included do
    parent_class = self

    after_destroy :destroy_associated_blocks

    has_many :block_slots, -> { where(block_record_type: parent_class.name).order(:position) },
             foreign_key: 'block_record_id',
             dependent: :destroy
    # has_one :block_record, as: :block_record, dependent: :destroy

    accepts_nested_attributes_for :block_slots, allow_destroy: true

    # TODO: DF 08/04/17 - under some condition if a block is saved without a block_id, the record will crash

    # TODO: rename block_slots to blocks and get rid of this method?
    def blocks(options = {})
      layout = options.fetch(:layout, nil)

      instance_variable_get("@#{layout}_blocks") || instance_variable_set("@#{layout}_blocks", begin
        if layout.present?
          block_slots.select { |bs| bs.layout == layout.to_s }.collect(&:block)
        else
          block_slots.collect(&:block)
        end
      end)
    end

    private

      def destroy_associated_blocks
        block_slots.includes(:block).each { |block_slot| block_slot.block&.destroy }
        block_slots.destroy_all
      end
  end
end
