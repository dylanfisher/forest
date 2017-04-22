class TextBlock < BaseBlock
  def self.permitted_params
    [:text]
  end

  def self.display_name
    'Text Block'
  end

  def self.display_icon
    'glyphicon glyphicon-align-left'
  end
end
