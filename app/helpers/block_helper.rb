module BlockHelper
  def render_blocks(record, options = {})
    return if (record.blank? || !record.respond_to?(:blocks))

    begin
      block_layout = options[:block_layout].presence || BlockLayout.default_layout

      if block_layout.is_a?(Symbol)
        block_layout = BlockLayout.find_by_slug(block_layout)
      end

      collection = options.delete(:collection) || record.blocks(block_layout: block_layout)

      if collection.present?
        content_tag :div, class: "blocks block-layout--#{block_layout.slug}" do
          collection.each do |block|
            next if block.hidden?
            begin
              concat render 'blocks/show', block: block
            rescue Exception => e
              forest_admin_error(e)
            end
          end
        end
      end
    rescue Exception => e
      forest_admin_error(e)
    end
  end
end
