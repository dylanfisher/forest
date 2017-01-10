class TitleBlock < BaseBlock
  has_many :page_slots, as: :blockable

  def self.permitted_params
    [:title]
  end

  def permitted_params
    self.class.permitted_params
  end
end
