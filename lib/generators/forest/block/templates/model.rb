<% module_namespacing do -%>
class <%= class_name %> < BaseBlock
  def self.permitted_params
    [<%= attributes.collect { |attribute| ":#{attribute.name}" }.join(', ') %>]
  end

  def self.display_name
    '<%= class_name.titleize %>'
  end

  # def self.display_icon
  #   'glyphicon glyphicon-align-left'
  # end
end
<% end -%>
