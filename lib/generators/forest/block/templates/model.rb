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

  # def self.display_icon
  #   'glyphicon glyphicon-align-left'
  # end
end
<% end -%>
