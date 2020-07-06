class MediaItemsController < ForestController
  before_action :set_media_item, only: [:show]

  def show
  end

  private

  def set_media_item
    @media_item = MediaItem.find_by_slug(params[:id])
  end
end
