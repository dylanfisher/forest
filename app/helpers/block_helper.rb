module BlockHelper

  def render_blocks(blocks)
    content_tag :div, class: 'blocks' do
      render partial: 'blocks/show', collection: blocks, as: 'block', cached: true
    end
  end

end
