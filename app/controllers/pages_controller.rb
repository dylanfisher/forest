class PagesController < ForestController
  include BlockableControllerConcerns
  include FilterControllerScopes

  layout 'admin', except: [:show]
  # layout Proc.new { |controller| 'admin' if admin? }

  before_action :set_page, only: [:show, :edit, :update, :destroy, :versions, :version, :restore]
  before_action :set_paper_trail_whodunnit

  has_scope :by_parent_page
  has_scope :title_like

  def index
    if request.format.json?
      @pages = apply_scopes(Page).by_title.page params[:page]
    else
      @parent_pages = apply_scopes(Page.includes(:versions, immediate_children: :versions)).parent_pages.page params[:page]
      @pages = apply_scopes(Page).by_title.page params[:page]
    end

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
    @page.reify_block_slots!

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
    unless @page
      raise ActionController::RoutingError.new('Not Found')
    end

    authorize @page
    @menus = nil

    redirect_to edit_page_path(@page) if admin?
    # TODO
    # @menus = Menu.by_page_group @page_groups if @page_groups.any?
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
      if blockable_record_is_valid?
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
    set_block_record

    # TODO: Handle block type deletion
    parse_block_attributes @page, record_type: 'page'

    @page.assign_attributes page_params

    respond_to do |format|
      if blockable_record_is_valid?
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
      # TODO: Move these block_slots_attributes into a concern
      params.require(:page).permit(:title, :slug, :description, :status, :version_id, :featured_image_id,
        :media_item_ids, :block_slot_cache, :parent_page_id, :ancestor_page_id, :scheduled_date, :path,
        block_slots_attributes: [
          :id, :_destroy, :page_id, :page_version_id, :block_id, :block_type, :block_previous_version_id,
          :layout, :position, :block_record_type, :block_record_id, :block_fields, *BlockType.block_type_params,
        ]
      )
    end

    def set_page
      # TODO: clean up page slug lookup
      if action_name == 'show' && public?
        # TODO: Published scope
        # TODO: now that this will be using published scope all the time, need a way on frontend
        # to show that the page is in draft, and to link admins to the draft preview.
        if params[:preview]
          @page = Page.find_by_path(params[:page_path])
        else
          @page = Page.find_by_path(params[:page_path]).current_published_version
        end
      else
        @page = Page.includes(block_slots: :block).find_by_path(params[:id] || params[:page_path])
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

    def set_block_record
      @block_record = @page.block_record || @page.build_block_record
    end
end
