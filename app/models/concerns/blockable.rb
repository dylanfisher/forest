module Blockable
  extend ActiveSupport::Concern

  included do
    parent_class = self

    after_save :set_blockable_metadata

    has_many :block_slots, -> { order(:position) },
             as: :block_record,
             inverse_of: :block_record,
             foreign_key: 'block_record_id',
             dependent: :destroy

    accepts_nested_attributes_for :block_slots, allow_destroy: true
  end

  class_methods do
    def blockable?
      true
    end
  end

  def blockable?
    true
  end

  def blocks(options = {})
    block_layout = options.fetch(:block_layout, BlockLayout.default_layout)
    block_layout_name = block_layout.try(:slug).try(:underscore).presence || 'default'
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
      Forest::BlockSet.new b.collect(&:block).select(&:display?)
    end)
  end

  def featured_image_from_blocks
    blocks.find { |b| b.try(:media_item).present? && b.media_item.image? }.try(:media_item)
  end

  private

  # Blockable metadata is a way to cache and store data on the blockable record itself to avoid expensive database lookups
  # when querying information about a record that may come from the reord's blocks.
  def set_blockable_metadata
    if self.respond_to?(:blockable_metadata)
      self.blockable_metadata['featured_image_url'] = featured_image_from_blocks.try(:attachment_url, :large)
      self.update_column(:blockable_metadata, self.blockable_metadata) if self.changes[:blockable_metadata].present?
    end
  end
end
