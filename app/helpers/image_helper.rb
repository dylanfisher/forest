module ImageHelper

  def responsive_image(media_item, options = {})
    return if media_item.blank?
    classes = options.fetch :classes, nil
    image_set_tag media_item.attachment.url(:small), {
        media_item.attachment.url(:medium) => '600w',
        media_item.attachment.url(:large) => '1200w',
        media_item.attachment.url(:huge) => '2000w'
      },
      options.merge(
        sizes: options.fetch(:sizes, '100vw'),
        class: "responsive-image #{classes}"
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
