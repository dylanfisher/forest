class Admin::PagesController < Admin::ForestController
  before_action :set_page, only: [:show, :edit, :update, :destroy]

  has_scope :by_parent_page
  has_scope :title_like

  def index
    if request.format.json?
      @pages = apply_scopes(Page).by_title.where.not(id: params[:current_record]).page params[:page]
    else
      @parent_pages = apply_scopes(Page).parent_pages.page params[:page]
      @pages = apply_scopes(Page).by_title.page params[:page]
    end

    authorize @pages
    respond_to :html, :json
  end

  # def show
  #   unless @page
  #     raise ActionController::RoutingError.new('Not Found')
  #   end
  #   authorize @page
  #   redirect_to edit_admin_page_path(@page)
  # end

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
        :title, :slug, :description, :status, :featured_image_id,
        :media_item_ids, :parent_page_id, :ancestor_page_id, :scheduled_date, :path,
        **BlockSlot.blockable_params
      ]
      # TODO: come up with a better pattern for adding additional params via the host app, rather than
      # just permitting all other column_names of the class.
      column_names = (@page.class.column_names.collect(&:to_sym) - page_attributes).reject { |a| [:id, :created_at, :updated_at].include?(a) }
      permitted_attributes = page_attributes + column_names
      params.require(:page).permit(permitted_attributes)
    end

    def set_page
      @page = Page.find(params[:id])
    end
end
