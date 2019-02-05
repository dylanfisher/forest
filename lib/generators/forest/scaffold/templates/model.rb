<% module_namespacing do -%>
class <%= class_name %> < Forest::ApplicationRecord
<% unless options.skip_blockable? -%>
  include Blockable
<% end -%>
<% unless options.skip_sluggable? -%>
  include Sluggable
<% end -%>
<% unless options.skip_statusable? -%>
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
