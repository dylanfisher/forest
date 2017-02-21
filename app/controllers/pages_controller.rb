class PagesController < ForestController
  include BlockableControllerConcerns
  include FilterControllerScopes

  layout 'admin', except: [:show]

  before_action :set_page, only: [:show, :edit, :update, :destroy, :versions, :version, :restore]
  # before_action :set_paper_trail_whodunnit

  has_scope :by_status

  def index
    @pages = apply_scopes(Page).page params[:page]
    authorize @pages
  end

  def versions
    authorize @page
    @versions = @page.versions
    status = params[:by_status] && Page.statuses[params[:by_status]]
    if status
      @versions = @versions.where_object(status: status)
    end
    @versions = @versions.reorder(created_at: :desc, id: :desc).page params[:page]
  end

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

  def new
    @page = Page.new
    authorize @page
  end

  def edit
    authorize @page
    set_blockable_record
  end

  def create
    @page = Page.new
    authorize @page
    set_blockable_record

    # TODO: Handle block type deletion
    parse_block_attributes @page, record_type: 'page'

    @page.assign_attributes page_params

    respond_to do |format|
      if @page.valid?
        save_page @page
        format.html { redirect_to edit_page_path(@page), notice: 'Page was successfully created.' }
        format.json { render :show, status: :created, location: @page }
      else
        format.html { render :new }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @page

    # TODO: Handle block type deletion
    parse_block_attributes @page, record_type: 'page'

    @page.assign_attributes page_params

    respond_to do |format|
      if @page.valid?
        save_page @page
        format.html { redirect_to edit_page_path(@page), notice: 'Page was successfully updated.' }
        format.json { render :show, status: :ok, location: @page }
      else
        format.html { render :edit }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @page
    @page.destroy
    respond_to do |format|
      format.html { redirect_to pages_url, notice: 'Page was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def page_params
      params.require(:page).permit(:title, :slug, :description, :status, :version_id, :featured_image_id, :media_item_ids, :page_slot_cache,
        page_slots_attributes: [:id, :_destroy, :page_id, :page_version_id, :blockable_id, :blockable_type, :blockable_previous_version_id, :position, :blockable_record_type, :blockable_record_id, *BlockType.block_type_params])
    end

    def set_page
      if action_name == 'show'
        # TODO: Published scope
        @page = Page.friendly.find(params[:id]) # Don't eager load associations when cached in show
      else
        @page = Page.includes(page_slots: :blockable).friendly.find(params[:id])
      end

      @record = @page

      # TODO: update page title as necessary
      @page_title = @page.try(:title)
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
