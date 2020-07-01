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
    'glyphicon glyphicon-picture'
  end
<% elsif class_name.match(/video/i) -%>
  def self.display_icon_name
    'glyphicon glyphicon-play'
  end
<% elsif class_name.match(/title/i) -%>
  def self.display_icon_name
    'glyphicon glyphicon-font'
  end
<% elsif class_name.match(/text/i) -%>
  def self.display_icon_name
    'glyphicon glyphicon-align-left'
  end
<% elsif class_name.match(/accordion/i) -%>
  def self.display_icon_name
    'glyphicon glyphicon-th-list'
  end
<% else -%>
  # def self.display_icon_name
  #   'glyphicon glyphicon-align-left'
  # end
<% end -%>
end
<% end -%>
