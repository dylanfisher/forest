class PageGroup < ApplicationRecord
  belongs_to :page, inverse_of: :page_groups
  belongs_to :parent_page, class_name: 'Page', inverse_of: :page_groups
  belongs_to :ancestor_page, class_name: 'Page', inverse_of: :page_groups

  has_and_belongs_to_many :menus

  scope :by_level, -> { order(:level, :page_id, :parent_page_id, :id) }
  scope :uniq_by_slug, -> { select('distinct on (page_groups.slug, page_groups.parent_page_id) *') }
  scope :title_like, -> string { where('page_groups.title ILIKE ?', "%#{string}%") }
end
