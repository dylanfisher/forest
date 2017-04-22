<% module_namespacing do -%>
class <%= class_name %> < ApplicationRecord
  include Blockable
  include FilterModelScopes
  include Searchable
  include Statusable

  # has_paper_trail

  # before_validation :generate_slug

  # validates :slug, presence: true, uniqueness: true

  # has_one :current_version, -> { reorder(created_at: :desc, id: :desc) }, class_name: "PaperTrail::Version", foreign_key: 'item_id'
  # has_one :current_published_version, -> { reorder(created_at: :desc, id: :desc).where_object(status: 1) }, class_name: "PaperTrail::Version", foreign_key: 'item_id'

  # def generate_slug
  #   self.slug = title.parameterize if changed.include?('slug')
  # end

  # def to_param
  #   slug
  # end
end
<% end -%>
