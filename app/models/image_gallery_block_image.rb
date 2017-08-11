class ImageGalleryBlockImage < ApplicationRecord
  belongs_to :image_gallery_block
  belongs_to :image, class_name: 'MediaItem'
end
