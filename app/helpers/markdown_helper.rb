require 'redcarpet/render_strip'

module MarkdownHelper
  def md(text)
    parser.render(text.to_s).html_safe
  end

  def stripdown(text)
    stripper.render(text.to_s).squish
  end

  private

  def parser
    @_forest_md_parser ||= Redcarpet::Markdown.new(renderer, Forest::MarkdownRenderer.options)
  end

  def stripper
    @_forest_md_stripper ||= Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
  end

  def renderer
    @_forest_md_renderer ||= Forest::MarkdownRenderer.new(Forest::MarkdownRenderer.render_options)
  end
end
