module BlockHelper

  def render_blocks(record, options = {})
    begin
      block_layout = options.fetch(:block_layout, BlockLayout.default_layout)
      if block_layout.is_a?(Symbol)
        block_layout = BlockLayout.find_by_slug(block_layout)
      end

      content_tag :div, class: "blocks block-layout--#{block_layout.slug}" do
        render partial: 'blocks/show', collection: record.blocks(block_layout: block_layout), as: 'block'
      end
    rescue Exception => e
      forest_admin_error(e)
    end
  end

end
