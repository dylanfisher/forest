module BlockHelper

  def render_blocks(record, options = {})
    return if record.blank?

    begin
      block_layout = options[:block_layout].presence || BlockLayout.default_layout

      if block_layout.is_a?(Symbol)
        block_layout = BlockLayout.find_by_slug(block_layout)
      end

      collection = record.blocks(block_layout: block_layout).reject(&:hidden?)

      if collection.present?
        content_tag :div, class: "blocks block-layout--#{block_layout.slug}" do
          render partial: 'blocks/show', collection: collection, as: 'block'
        end
      end
    rescue Exception => e
      forest_admin_error(e)
    end
  end

end
