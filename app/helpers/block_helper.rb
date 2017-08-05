module BlockHelper

  def render_blocks(record, options = {})
    # TODO: DF 08/05/17 - only render blocks associated with current version of record
    layout = options.fetch(:layout, nil)
    blocks = record.blocks(layout: layout)
    content_tag :div, class: 'blocks' do
      render partial: 'blocks/show', collection: blocks, as: 'block', cached: true
    end
  end

end
