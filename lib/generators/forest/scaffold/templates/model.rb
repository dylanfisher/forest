<% module_namespacing do -%>
class <%= class_name %> < Forest::ApplicationRecord
  include Blockable
  include Sluggable
  include Statusable

  # def self.resource_description
  #   'Briefly describe this resource.'
  # end
end
<% end -%>
