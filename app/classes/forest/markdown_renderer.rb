require 'redcarpet/render_strip'

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
end
