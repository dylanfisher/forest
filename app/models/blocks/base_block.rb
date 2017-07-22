class BaseBlock < ApplicationRecord
  self.abstract_class = true

  has_paper_trail class_name: 'BlockVersion',
                  meta: { block_record_id: :block_record_id }

  has_one :block_slot, class_name: 'BlockSlot', foreign_key: 'block_id'

  def self.display_name
    'Base Block'
  end

  def self.display_icon
    'glyphicon glyphicon-tree-conifer'
  end

  def display_name
    self.class.display_name
  end

  def display_icon
    self.class.display_icon
  end

  def permitted_params
    self.class.permitted_params
  end

  def block_record_id
    block_slot.block_record_id
  end
end
