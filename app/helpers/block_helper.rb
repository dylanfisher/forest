module BlockHelper

  def render_blocks(record, options = {})
    layout = options.fetch(:layout, nil)

    content_tag :div, class: 'blocks' do
      render partial: 'blocks/show', collection: record.blocks(layout: layout), as: 'block', cached: true
    end
  end

end
