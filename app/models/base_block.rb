class BaseBlock < ApplicationRecord
  self.abstract_class = true

  has_many :page_slots, as: :blockable

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

end
