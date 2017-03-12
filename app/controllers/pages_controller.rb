class PagesController < ForestController
  include BlockableControllerConcerns
  include FilterControllerScopes

  layout 'admin', except: [:show]

  before_action :set_page, only: [:show, :edit, :update, :destroy, :versions, :version, :restore]
  before_action :set_parent_page_pages, only: [:edit, :update, :new]
  before_action :set_paper_trail_whodunnit

  has_scope :by_parent_page
  has_scope :title_like

  def index
    @pages = apply_scopes(Page).parent_pages.page params[:page]
    authorize @pages
    respond_to :html, :json
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
    set_block_record
  end

  def edit
    authorize @page
    set_block_record
  end

  def create
    @page = Page.new
    authorize @page

    # TODO: if a record is not valid when saving, any new blocks will be lost
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
      params.require(:page).permit(:title, :slug, :description, :status, :version_id, :featured_image_id, :media_item_ids, :page_slot_cache, :parent_page_id, :ancestor_page_id, page_group_ids: [],
        page_slots_attributes: [:id, :_destroy, :page_id, :page_version_id, :block_id, :block_type, :block_previous_version_id, :position, :block_record_type, :block_record_id, *BlockType.block_type_params])
    end

    def set_page
      # TODO: clean up page slug lookup
      page_slug = params[:page_path].split('/').reject(&:blank?).last if params[:page_path]
      page_slug = page_slug.presence || params[:id]
      if action_name == 'show'
        # TODO: Published scope
        @page = Page.find_by_slug(page_slug) # Don't eager load associations when cached in show
      else
        @page = Page.includes(page_slots: :block).find_by_slug(page_slug)
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

    def set_parent_page_pages
      if @page&.parent_page_id
        @parent_page_pages = Page.page(1) + Page.where(id: @page.parent_page_id)
      else
        @parent_page_pages = Page.page(1)
      end
    end

    def set_block_record
      @block_record = @page.block_record || @page.build_block_record
    end
end
