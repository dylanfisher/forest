class PagesController < ForestController
  include BlockableControllerConcerns
  include FilterControllerScopes

  layout 'admin', except: [:show]

  before_action :set_page, only: [:show, :edit, :update, :destroy]

  has_scope :by_parent_page
  has_scope :title_like

  def index
    if request.format.json?
      @pages = apply_scopes(Page).by_title.page params[:page]
    else
      @parent_pages = apply_scopes(Page).parent_pages.page params[:page]
      @pages = apply_scopes(Page).by_title.page params[:page]
    end

    authorize @pages
    respond_to :html, :json
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

  def new
    @page = Page.new
    authorize @page
  end

  def edit
    authorize @page
  end

  def create
    @page = Page.new
    authorize @page

    respond_to do |format|
      if @page.update(page_params)
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

    respond_to do |format|
      if @page.update(page_params)
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
      params.require(:page).permit(:title, :slug, :description, :status, :featured_image_id,
        :media_item_ids, :parent_page_id, :ancestor_page_id, :scheduled_date, :path,
        block_slots_attributes: [
          :id, :_destroy, :block_id, :block_kind, :block_kind_id,
          :layout, :position, :block, :block_record_type, :block_record_id, :block_fields, block_attributes: [*BlockKind.block_kind_params]
        ]
      )
    end

    def set_page
      # TODO: clean up page slug lookup
      if action_name == 'show' && public?
        # TODO: Published scope
        # TODO: now that this will be using published scope all the time, need a way on frontend
        # to show that the page is in draft, and to link admins to the draft preview.
        @page = Page.find_by_path(params[:page_path])
      else
        @page = Page.find_by_path(params[:id] || params[:page_path])
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
end
