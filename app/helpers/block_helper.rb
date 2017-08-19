module BlockHelper

  def render_blocks(record, options = {})
    block_layout = options.fetch(:block_layout, BlockLayout.default_layout)
    if block_layout.is_a?(Symbol)
      block_layout = BlockLayout.find_by_slug(block_layout)
    end

    content_tag :div, class: 'blocks' do
      render partial: 'blocks/show', collection: record.blocks(block_layout: block_layout), as: 'block'
    end
  end

end
