class ImageBlock < BaseBlock
  belongs_to :image, class_name: 'MediaItem'

  def self.permitted_params
    [:image_id, :caption]
  end

  def self.display_name
    'Image Block'
  end

  def self.display_icon
    'glyphicon glyphicon-picture'
  end
end
