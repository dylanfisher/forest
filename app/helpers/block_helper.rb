module BlockHelper

  def render_blocks(record, options = {})
    layout = options.fetch(:layout, nil)

    # if record.try(:version)
    #   blocks = record.blocks_from_version(layout: layout)
    # else
    #   blocks = record.blocks(layout: layout)
    # end

    content_tag :div, class: 'blocks' do
      render partial: 'blocks/show', collection: record.blocks(layout: layout), as: 'block', cached: true
    end
  end

end
