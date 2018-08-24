<% module_namespacing do -%>
class <%= class_name %> < Forest::ApplicationRecord
  include Blockable
  include Sluggable
  include Statusable

<% attributes.each do |attribute| %><% if attribute.reference? -%>
  belongs_to :<%= attribute.name %>

<% end -%><% end -%>
  # def self.resource_description
  #   'Briefly describe this resource.'
  # end
end
<% end -%>
