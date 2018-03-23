class Forest::MarkdownRenderer < Redcarpet::Render::HTML
  def self.options
    {
      hard_wrap: true,
      autolink: true,
      tables: true,
      safe_links_only: true,
      no_intra_emphasis: true,
      space_after_headers: true
    }
  end

  def postprocess(full_document)
    begin
      without_leading_trailing_paragraphs = Regexp.new(/\A<p>(.*)<\/p>\Z/mi).match(full_document)[1]
      unless without_leading_trailing_paragraphs.include?('<p>')
        full_document = without_leading_trailing_paragraphs
      end
      full_document = Redcarpet::Render::SmartyPants.render(full_document)
    rescue Exception => e
      logger.error { "Error in Forest::MarkdownRenderer postprocess #{e.inspect}" }
    end
    full_document
  end
end
