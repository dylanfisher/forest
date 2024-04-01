<% module_namespacing do -%>
class <%= class_name %> < Forest::ApplicationRecord
<% unless options.skip_blockable? || options.skip_all? -%>
  include Blockable
<% end -%>
<% unless options.skip_sluggable? || options.skip_all? -%>
  include Sluggable
<% end -%>
<% unless options.skip_statusable? || options.skip_all? -%>
  include Statusable
<% end -%>

<% attributes.each do |attribute| %><% if attribute.reference? -%>
  belongs_to :<%= attribute.name %>

<% end -%><% end -%>
  # def self.resource_description
  #   'Briefly describe this resource.'
  # end
end
<% end -%>
