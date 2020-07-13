class Admin::PagesController < Admin::ForestController
  before_action :set_page, only: [:show, :edit, :update, :destroy]
  before_action :set_block_layout, only: [:create, :edit, :new]
  before_action :set_block_kinds, only: [:create, :edit, :new]

  has_scope :by_parent_page
  has_scope :title_like

  def index
    if request.format.json?
      @pagy, @pages = pagy apply_scopes(Page).by_title.where.not(id: params[:current_record])
    else
      # TODO: fuzzy searching doesn't work properly with page hierarchy
      @pagy_parent_pages, @parent_pages = pagy apply_scopes(Page.includes(:immediate_children)).parent_pages
      @pagy, @pages = pagy apply_scopes(Page).by_title
    end

    authorize @pages
    respond_to :html, :json
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
        format.html { redirect_to edit_admin_page_path(@page), notice: 'Page was successfully created.' }
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
        format.html { redirect_to edit_admin_page_path(@page), notice: 'Page was successfully updated.' }
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
      format.html { redirect_to admin_pages_url, notice: 'Page was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def page_params
    page_attributes = [
      :title, :slug, :description, :status, :featured_image_id, :redirect,
      :media_item_ids, :parent_page_id, :ancestor_page_id, :scheduled_date, :path,
      **BlockSlot.blockable_params
    ]
    # TODO: come up with a better pattern for adding additional params via the host app, rather than
    # just permitting all other column_names of the class.
    column_names = (@page.class.column_names.collect(&:to_sym) - page_attributes).reject { |a| [:id, :created_at, :updated_at].include?(a) }
    # Attributes from store_accessors
    stored_attributes = @page.class.stored_attributes.values.flatten
    permitted_attributes = page_attributes + column_names + stored_attributes
    params.require(:page).permit(permitted_attributes)
  end

  def set_page
    @page = Page.includes(block_slots: [:block_kind, :block]).find(params[:id])
  end

  def set_block_layout
    @block_layout = BlockLayout.find_by_slug('default')
  end

  def set_block_kinds
    @block_kinds = BlockKind.all
  end
end
