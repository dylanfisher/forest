module Blockable
  extend ActiveSupport::Concern

  included do
    parent_class = self

    before_save :touch_self

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
      block_layout = options.fetch(:block_layout, nil)
      block_layout_name = block_layout.try(:slug).try(:underscore).presence || 'all'
      block_type = options.fetch(:kind, nil)

      instance_variable_get("@#{block_layout_name}_blocks") || instance_variable_set("@#{block_layout_name}_blocks", begin
        if block_type
          b = block_slots.includes(:block).where(block_kind_id: block_type.kind.id)
        else
          b = block_slots.includes(:block, :block_layout)
        end
        if block_layout.present?
          b = b.select { |bs| bs.block_layout == block_layout }
        end
        b.collect(&:block)
      end)
    end

    private

      def touch_self
        if self.respond_to?(:updated_at)
          self.updated_at = Time.now
        end
      end
  end
end
