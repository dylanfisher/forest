module BlockHelper

  def render_blocks(record, options = {})
    block_layout = options.fetch(:block_layout, BlockLayout.default_layout)

    content_tag :div, class: 'blocks' do
      render partial: 'blocks/show', collection: record.blocks(block_layout: block_layout), as: 'block'
    end
  end

end
