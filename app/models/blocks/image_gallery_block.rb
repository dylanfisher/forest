class ImageGalleryBlock < BaseBlock
  has_many :image_gallery_block_images
  has_many :images, through: :image_gallery_block_images

  def self.permitted_params
    [
      :image_ids
    ]
  end

  def self.display_name
    'Image Gallery Block'
  end

  def self.display_icon
    'glyphicon glyphicon-picture'
  end
end
