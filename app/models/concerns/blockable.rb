module Blockable
  extend ActiveSupport::Concern

  included do
    parent_class = self

    before_save :touch_self
    after_save :set_blockable_metadata

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
        Forest::BlockSet.new b.collect(&:block)
      end)
    end

    def featured_image_from_blocks
      blocks.find { |b| b.try(:media_item).present? }.try(:media_item)
    end

    private

      def touch_self
        if self.respond_to?(:updated_at)
          self.updated_at = Time.now
        end
      end

      # Blockable metadata is a way to cache and store data on the blockable record itself to avoid expensive database lookups
      # when querying information about a record that may come from the reord's blocks.
      def set_blockable_metadata
        if self.respond_to?(:blockable_metadata)
          self.blockable_metadata['featured_image_url'] = featured_image_from_blocks.try(:attachment).try(:url, :large)
          self.update_column(:blockable_metadata, self.blockable_metadata)
        end
      end
  end
end
