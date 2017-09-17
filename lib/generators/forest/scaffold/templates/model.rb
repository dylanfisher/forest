<% module_namespacing do -%>
class <%= class_name %> < Forest::ApplicationRecord
  include Blockable
  include Sluggable
  # include Statusable
end
<% end -%>
