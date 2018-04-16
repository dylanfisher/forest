class Forest::MarkdownRenderer < Redcarpet::Render::HTML
  def self.options
    {
      autolink: true,
      no_intra_emphasis: true,
      tables: true,
      space_after_headers: true
    }
  end

  def self.render_options
    {
      hard_wrap: true,
      safe_links_only: true
    }
  end

  def postprocess(full_document)
    return full_document if full_document.blank?

    begin
      without_leading_trailing_paragraphs = Regexp.new(/\A<p>(.*)<\/p>\Z/mi).match(full_document)[1]
      unless without_leading_trailing_paragraphs.include?('<p>')
        full_document = without_leading_trailing_paragraphs
      end
    rescue StandardError => e
    end

    Redcarpet::Render::SmartyPants.render(full_document)
  end
end
