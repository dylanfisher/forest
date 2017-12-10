class Admin::MenusController < Admin::ForestController
  before_action :set_menu, only: [:show, :edit, :update, :destroy]
  before_action :set_pages, only: [:edit, :update, :new]

  # GET /menus
  def index
    @menus = apply_scopes(Menu.order(id: :asc)).page(params[:page])
    authorize @menus
  end

  # GET /menus/1
  def show
  end

  # GET /menus/new
  def new
    @menu = Menu.new
    authorize @menu
  end

  # GET /menus/1/edit
  def edit
    authorize @menu
  end

  # POST /menus
  def create
    @menu = Menu.new(menu_params)
    authorize @menu

    if @menu.save
      redirect_to edit_admin_menu_path(@menu), notice: 'Menu was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /menus/1
  def update
    authorize @menu
    if @menu.update(menu_params)
      redirect_to edit_admin_menu_path(@menu), notice: 'Menu was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /menus/1
  def destroy
    authorize @menu
    @menu.destroy
    redirect_to admin_menus_url, notice: 'Menu was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_menu
      @menu = Menu.find(params[:id])
    end

    def set_pages
      @pages = Page.page(1)
    end

    # Only allow a trusted parameter "white list" through.
    def menu_params
      params.require(:menu).permit(:title, :slug, :structure)
    end
end
