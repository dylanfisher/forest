class Forest::MarkdownRenderer < Redcarpet::Render::HTML
  include Redcarpet::Render::SmartyPants

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
    rescue Exception => e
    end
    full_document
  end
end
