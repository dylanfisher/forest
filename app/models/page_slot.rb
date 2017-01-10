class PageSlot < ApplicationRecord
  belongs_to :blockable, polymorphic: true
  # has_many :blocks, as: :blockable, class_name: 'PageSlot'
  # has_many :title_blocks, as: :blockable, class_name: 'PageSlot'

  # attr_accessor :title_block
end
