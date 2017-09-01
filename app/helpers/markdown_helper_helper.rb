module MarkdownHelperHelper
  def md(text)
    content_tag :div, class: 'markdown' do
      parser.render(text.to_s).html_safe
    end
  end

  private

    def parser
      @parser ||= Redcarpet::Markdown.new Forest::MarkdownRenderer.new(Forest::MarkdownRenderer.options)
    end
end
