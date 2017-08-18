class BlockLayout < ApplicationRecord
  has_many :block_slots

  scope :default_layout, -> { BlockLayout.find_by_slug('default') }
end
