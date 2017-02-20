class PagesController < ForestController
  include BlockableControllerConcerns
  include FilterControllerScopes

  layout 'admin', except: [:show]

  before_action :set_page, only: [:show, :edit, :update, :destroy, :versions, :version, :restore]
  before_action :set_blockable_record, only: [:edit, :update, :create]
  before_action :set_paper_trail_whodunnit

  # GET /pages
  # GET /pages.json
  def index
    @pages = apply_scopes(Page.includes(:versions)).by_title.page params[:page]
    authorize @pages
  end

  # GET /pages/1/versions
  # GET /pages/1/versions.json
  def versions
    authorize @page
    @versions = @page.versions
    status = params[:by_status] && Page.statuses[params[:by_status]]
    if status
      @versions = @versions.where_object(status: status)
    end
    @versions = @versions.reorder(created_at: :desc, id: :desc).page params[:page]
  end

  # GET /pages/1/restore
  # GET /pages/1/restore.json
  def restore
    authorize @page
    @version = @page.versions.find(params['version_id'])
    @page = @version.reify
    @page.reify_page_slots!

    respond_to do |format|
      if @page.save
        format.html { redirect_to page_versions_path(@page), notice: 'Page version was successfully restored.' }
        format.json { render :show, status: :ok, location: @page }
      else
        format.html { render :versions }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    authorize @page
  end

  def version
    authorize @page
    @version = @page.versions.find(params['version_id'])
    @page = @version.reify
    # TODO: some way to reify blocks for other versions
    render :show
  end

  # GET /pages/new
  def new
    @page = Page.new
    authorize @page
  end

  # GET /pages/1/edit
  def edit
    authorize @page
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = Page.new
    authorize @page

    # TODO: Handle block type deletion
    parse_block_attributes

    @page.assign_attributes page_params

    respond_to do |format|
      if @page.valid?
        save_page
        format.html { redirect_to edit_page_path(@page), notice: 'Page was successfully created.' }
        format.json { render :show, status: :created, location: @page }
      else
        format.html { render :new }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pages/1
  # PATCH/PUT /pages/1.json
  def update
    authorize @page

    # TODO: Handle block type deletion
    parse_block_attributes

    @page.assign_attributes page_params

    respond_to do |format|
      if @page.valid?
        save_page
        format.html { redirect_to edit_page_path(@page), notice: 'Page was successfully updated.' }
        format.json { render :show, status: :ok, location: @page }
      else
        format.html { render :edit }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    authorize @page
    @page.destroy
    respond_to do |format|
      format.html { redirect_to pages_url, notice: 'Page was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_params
      params.require(:page).permit(:title, :slug, :description, :status, :version_id, :featured_image_id, :media_item_ids, :page_slot_cache,
        page_slots_attributes: [:id, :_destroy, :page_id, :page_version_id, :blockable_id, :blockable_type, :blockable_previous_version_id, :position, :blockable_record_type, :blockable_record_id, *BlockType.block_type_params])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_page
      @page = Page.friendly.find(params[:id])
      if action_name == 'show'
        # Don't eager load associations when cached in show
        @page = Page.friendly.find(params[:id])
      else
        @page = Page.includes(page_slots: :blockable).friendly.find(params[:id])
      end

      @page_title = @page.title
      # TODO: Published page scope. Maybe add a association on Page so that a page has_one current_published_version.
      # This could be set in a after_save filter when updating page statuses.
      # @page = Page.friendly.find(params[:id]).versions.where_object(status: 1).last.reify
    rescue ActiveRecord::RecordNotFound
      if action_name == 'show' && Rails.env.production?
        redirect_to root_url, flash: { error: 'Record not found.' }
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    def set_blockable_record
      @blockable_record = @page.blockable_record || @page.build_blockable_record
    end

end
