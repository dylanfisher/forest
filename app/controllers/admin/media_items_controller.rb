class Admin::MediaItemsController < Admin::ForestController
  before_action :set_media_item, only: [:show, :edit, :update, :reprocess, :destroy]

  has_scope :by_date
  has_scope :by_content_type
  has_scope :by_extension
  has_scope :videos, type: :boolean
  has_scope :audio, type: :boolean
  has_scope :images, type: :boolean
  has_scope :pdfs, type: :boolean
  has_scope :fuzzy_search

  # GET /media_items
  def index
    if params[:hidden] == 'true'
      @pagy, @media_items = pagy(apply_scopes(MediaItem.all).by_id.hidden, items: 36)
    else
      @pagy, @media_items = pagy(apply_scopes(MediaItem.all).by_id.is_not_hidden, items: 36)
    end
    authorize @media_items, :admin_index?

    if params[:layout].blank? || params[:layout] != 'list'
      @layout = :grid
    else
      @layout = :list
    end

    respond_to :html, :json
  end

  # GET /media_items/1
  def show
  end

  # GET /media_items/new
  def new
    @media_item = MediaItem.new
    authorize @media_item
  end

  # GET /media_items/1/edit
  def edit
    authorize @media_item
  end

  # POST /media_items
  def create
    @media_item = MediaItem.new(media_item_params)
    authorize @media_item

    respond_to do |format|
      if @media_item.save
        format.html { redirect_to edit_admin_media_item_path(@media_item), notice: 'Media item was successfully created.' }
        format.json {
          html_content = render_to_string(partial: 'admin/media_items/media_item_grid_layout', locals: { media_item: @media_item }, layout: false, formats: [:html])
          render json: { attachmentPartial: html_content }
        }
      else
        format.html { render :new }
        format.json { render json: @media_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /media_items/1
  def update
    authorize @media_item
    if @media_item.update(media_item_params)
      redirect_to edit_admin_media_item_path(@media_item), notice: 'Media item was successfully updated.'
    else
      render :edit
    end
  end

  # PATCH/PUT /media_items/1/reprocess
  def reprocess
    authorize @media_item
    derivative_name = params[:derivative_name]
    if derivative_name.blank?
      redirect_to edit_admin_media_item_path(@media_item), notice: 'Failed to reprocess derivative. Derivative name must be specified.'
    else
      @media_item.reprocess_derivative(derivative_name.to_sym)
      redirect_to edit_admin_media_item_path(@media_item), notice: 'Media item derivative is being reprocessed in the background. Refresh this page in a moment to see the update. If this error continues to fail for large derivative sizes, you\'ll need to upload a smaller version of the file.'
    end
  end

  # PATCH/PUT /media_items
  def update_multiple
    if params['selected']&.any?
      @media_items = MediaItem.where(id: params[:selected])
      authorize @media_items
      if params[:bulk_actions] == 'delete'
        @media_items.destroy_all
        notice = 'Media items were successfully destroyed.'
      else
        notice = 'Please select a bulk action.'
      end
    else
      notice = 'Please select a media item.'
    end
    redirect_to admin_media_items_url, notice: notice
  end

  # DELETE /media_items/1
  def destroy
    authorize @media_item
    @media_item.destroy
    redirect_to admin_media_items_url, notice: 'Media item was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_media_item
    @media_item = MediaItem.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def media_item_params
    params.require(:media_item).permit(:title, :slug, :caption, :alternative_text, :description, :attachment, :selected, :point_of_interest_x, :point_of_interest_y, :retain_source, :vimeo_video_thumbnail_override_id, *MediaItem.localized_params, *MediaItem.additional_permitted_params)
  end
end
