class TitleBlock < BaseBlock
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
