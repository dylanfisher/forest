<% module_namespacing do -%>
class <%= class_name %> < Forest::ApplicationRecord
  include Blockable
  include FilterModelScopes
  include Searchable
  include Statusable

  # before_validation :generate_slug

  # validates :slug, presence: true, uniqueness: true

  # def generate_slug
  #   self.slug = title.parameterize if self.slug.blank? || changed.include?('slug')
  # end

  # def to_param
  #   slug
  # end
end
<% end -%>
