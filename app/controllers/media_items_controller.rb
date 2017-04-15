class MediaItemsController < ForestController
  before_action :set_media_item, only: [:show, :edit, :update, :destroy]

  layout 'admin', except: [:show]

  has_scope :by_date
  has_scope :by_content_type
  has_scope :search

  # GET /media_items
  def index
    @media_items = apply_scopes(MediaItem.all).by_id.page(params[:page]).per(36)
    authorize @media_items

    if params[:layout].blank? || params[:layout] != 'list'
      @layout = :grid
    else
      @layout = :list
    end
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
        format.html { redirect_to @media_item, notice: 'Media item was successfully created.'}
        format.json { render json: { files: [@media_item.to_jq_upload]}, status: :created, location: @media_item }
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
      redirect_to edit_media_item_path(@media_item), notice: 'Media item was successfully updated.'
    else
      render :edit
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
    redirect_to media_items_url, notice: notice
  end

  # DELETE /media_items/1
  def destroy
    authorize @media_item
    @media_item.destroy
    redirect_to media_items_url, notice: 'Media item was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_media_item
      @media_item = MediaItem.find_by_slug(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def media_item_params
      params.require(:media_item).permit(:title, :slug, :caption, :alternative_text, :description, :attachment, :selected)
    end
end
