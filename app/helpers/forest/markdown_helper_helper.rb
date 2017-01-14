module Forest
  module MarkdownHelperHelper
    def md(text)
        parser.render(text).html_safe
    end

    private

      def parser
        @parser ||= Redcarpet::Markdown.new(Forest::MarkdownRenderer.new, Forest::MarkdownRenderer.options)
      end
  end
end
