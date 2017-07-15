class BaseBlock < ApplicationRecord
  self.abstract_class = true

  has_paper_trail

  after_update :set_block_slot_previous_version

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

  private

    def set_block_slot_previous_version
      # self.block_slot.update_column :block_previous_version_id, self.versions.last.id
    end

end
