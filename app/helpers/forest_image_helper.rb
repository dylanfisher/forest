module ForestImageHelper
  def forest_uri_image_placeholder
    'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='
  end

  # Embed an SVG file inline, allowing it to be styled with CSS. This SVG must
  # reside in the engine's asset directory
  def forest_embedded_svg(filename, options = {})
    file = File.read(Forest::Engine.root.join('app', 'assets', 'images', filename))
    doc = Nokogiri::HTML::DocumentFragment.parse(file)
    svg = doc.at_css 'svg'
    svg['class'] = "#{svg['class']} #{options[:class]}" if options[:class].present?
    svg['id'] = options[:id] if options[:id].present?
    svg['style'] = "#{svg['style']} #{options[:style]}" if options[:style].present?
    svg['width'] = options[:width] if options[:width].present?
    svg['height'] = options[:height] if options[:height].present?
    doc.to_html.html_safe
  end
end
