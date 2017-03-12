class PageGroup < ApplicationRecord
  belongs_to :page, inverse_of: :page_groups
  belongs_to :parent_page, class_name: 'Page', inverse_of: :page_groups
  belongs_to :ancestor_page, class_name: 'Page', inverse_of: :page_groups
end
