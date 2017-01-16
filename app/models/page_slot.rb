class PageSlot < ApplicationRecord
  belongs_to :blockable, polymorphic: true
  alias_attribute :block, :blockable # TODO: rename blockable to block?
end
