<% module_namespacing do -%>
class <%= class_name %> < ApplicationRecord
  include FilterModelScopes
  include Blockable
  include Searchable
  include Statusable

  extend FriendlyId
  # friendly_id :title, use: :slugged

  # has_paper_trail

  # has_one :current_version, -> { reorder(created_at: :desc, id: :desc) }, class_name: "PaperTrail::Version", foreign_key: 'item_id'
  # has_one :current_published_version, -> { reorder(created_at: :desc, id: :desc).where_object(status: 1) }, class_name: "PaperTrail::Version", foreign_key: 'item_id'

  private

    # def should_generate_new_friendly_id?
    #   slug.blank?
    # end
end
<% end -%>
