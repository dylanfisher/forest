class ImageGalleryBlock < BaseBlock
  has_many :image_gallery_block_images, dependent: :destroy
  has_many :images, -> { order('image_gallery_block_images.position') }, through: :image_gallery_block_images

  accepts_nested_attributes_for :image_gallery_block_images, allow_destroy: true

  def self.permitted_params
    [image_ids: []]
  end

  def self.display_name
    'Image Gallery Block'
  end

  def self.display_icon
    'glyphicon glyphicon-picture'
  end
end
