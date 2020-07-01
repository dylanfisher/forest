<% module_namespacing do -%>
class <%= class_name %> < BaseBlock
<% attributes.each do |attribute| %><% if attribute.reference? -%>
  belongs_to :<%= attribute.name %>

<% end -%><% end -%>
  def self.permitted_params
    [<%= attributes.collect { |attribute| ":#{attribute.column_name}" }.join(', ') %>]
  end

  def self.display_name
    '<%= class_name.titleize %>'
  end

  # def self.description
  #   'Replace with a succinct description of what the block does'
  # end

<% if class_name.match(/image/i) -%>
  def self.display_icon_name
    'image<%= 's' if class_name.match(/gallery/i) -%>'
  end
<% elsif class_name.match(/video/i) -%>
  def self.display_icon_name
    'play'
  end
<% elsif class_name.match(/title/i) -%>
  def self.display_icon_name
    'type-h1'
  end
<% elsif class_name.match(/text/i) -%>
  def self.display_icon_name
    'justify-left'
  end
<% elsif class_name.match(/accordion/i) -%>
  def self.display_icon_name
    'list'
  end
<% else -%>
  # def self.display_icon_name
  #   'Replace with a relevant bootstrap icon name https://icons.getbootstrap.com/'
  # end
<% end -%>
end
<% end -%>
