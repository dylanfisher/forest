module ImageHelper
  # Embed an SVG file inline, allowing it to be styled with CSS.
  def embedded_svg(filename, options={})
    file = File.read(Rails.root.join('app', 'assets', 'images', 'svg', "#{filename}.svg"))
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css 'svg'
    if options[:class].present?
      svg['class'] = "#{svg['class']} #{options[:class]}"
    end
    if options[:id].present?
      svg['id'] = options[:id]
    end
    if options[:style].present?
      svg['style'] = "#{svg['style']} #{options[:style]}"
    end
    doc.to_html.html_safe
  end

  def responsive_image(media_item, options = {})
    # TODO: DF 08/04/17 - return a missing image if media item is blank?
    # return if media_item.blank?
    css_class = options.fetch :class, nil
    image_set_tag media_item.attachment.url(:small), {
        media_item.attachment.url(:medium) => '1200w',
        media_item.attachment.url(:large) => '2000w'
      },
      options.merge(
        sizes: options.fetch(:sizes, '100vw'),
        class: "responsive-image #{css_class}"
      )
  end

  # https://gist.github.com/mrreynolds/4fc71c8d09646567111f
  # Acts as a thin wrapper for image_tag and generates an srcset attribute for regular image tags
  # for usage with responsive images polyfills like picturefill.js, supports asset pipeline path helpers.
  #
  # image_set_tag 'pic_1980.jpg', { 'pic_640.jpg' => '640w', 'pic_1024.jpg' => '1024w', 'pic_1980.jpg' => '1980w' }, sizes: '100vw', class: 'my-image'
  #
  # => <img src="/assets/ants_1980.jpg" srcset="/assets/pic_640.jpg 640w, /assets/pic_1024.jpg 1024w, /assets/pic_1980.jpg 1980w" sizes="100vw" class="my-image">
  def image_set_tag(source, srcset = {}, options = {})
    srcset = srcset.map { |src, size| "#{asset_path(src)} #{size}" }.join(', ')
    image_tag source, options.merge(srcset: srcset)
  end

  # Prevent images from thrashing your page's layout with the image_jump_fix helper.
  #
  # <%= image_jump_fix block.media_item do %>
  #   <%= image_tag block.media_item.attachment.url(:medium) %>
  # <% end %>
  def image_jump_fix(media_item, options = {})
    width = media_item.try(:dimensions).try(:[], :width) || media_item.try(:attachment_width)
    height = media_item.try(:dimensions).try(:[], :height) || media_item.try(:attachment_height)
    tag_type = options.delete(:tag) || :div
    css_class = options[:class]

    if [width, height].all?
      ratio = height.to_f / width.to_f * 100
      padding_bottom = "padding-bottom: #{ratio}%;"
    end

    content_tag tag_type, class: "forest-image-jump-fix #{('forest-image-jump-fix--' + media_item.attachment_content_type.parameterize) if media_item.try(:attachment_content_type).present?} #{css_class}", style: padding_bottom do
      yield
    end
  end
end
