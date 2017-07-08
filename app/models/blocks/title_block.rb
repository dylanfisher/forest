class TitleBlock < BaseBlock
  validates_presence_of :title

  def self.permitted_params
    [:title]
  end

  def self.display_name
    'Title Block'
  end

  def self.display_icon
    'glyphicon glyphicon-font'
  end
end
