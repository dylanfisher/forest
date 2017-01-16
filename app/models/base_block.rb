class BaseBlock < ApplicationRecord
  self.abstract_class = true

  has_paper_trail

  after_update :set_page_slot_previous_version

  has_one :page_slot, class_name: 'PageSlot', foreign_key: 'blockable_id'

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

    def set_page_slot_previous_version
      self.page_slot.update_column :blockable_previous_version_id, self.versions.last.id
    end

end
