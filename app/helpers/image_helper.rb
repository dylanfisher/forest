module ImageHelper
  # Embed an SVG file inline, allowing it to be styled with CSS.
  def embedded_svg(filename, options={})
    file = File.read(Rails.root.join('app', 'assets', 'images', 'svg', "#{filename}.svg"))
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css 'svg'
    if options[:class].present?
      svg['class'] = options[:class]
    end
    doc.to_html.html_safe
  end

  def responsive_image(media_item, options = {})
    # TODO: DF 08/04/17 - return a missing image if media item is blank?
    # TODO: DF 08/04/17 - does it make sense to include the original dimensions as width and height attribtues?
    # return if media_item.blank?
    css_class = options.fetch :class, nil
    image_set_tag media_item.attachment.url(:small), {
        media_item.attachment.url(:medium) => '1200w',
        media_item.attachment.url(:large) => '2000w'
      },
      options.merge(
        sizes: options.fetch(:sizes, '100vw'),
        class: "responsive-image #{css_class}",
        width: media_item.try(:dimensions).try(:[], :width),
        height: media_item.try(:dimensions).try(:[], :height)
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
end
