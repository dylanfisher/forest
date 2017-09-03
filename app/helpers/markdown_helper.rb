require 'redcarpet/render_strip'

module MarkdownHelper
  def md(text)
    parser.render(text.to_s).html_safe
  end

  def stripdown(text)
    stripper.render(text.to_s)
  end

  private

    def parser
      @parser ||= Redcarpet::Markdown.new(Forest::MarkdownRenderer.new(Forest::MarkdownRenderer.options))
    end

    def stripper
      @stripper = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
    end
end
