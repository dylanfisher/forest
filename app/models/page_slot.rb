class PageSlot < ApplicationRecord
  belongs_to :blockable, polymorphic: true
  alias_attribute :block, :blockable # TODO: rename blockable to block?
  belongs_to :blockable_record, polymorphic: true

  after_save :update_blockable_record

  private

    def update_blockable_record
      # blockable_record
    end
end
