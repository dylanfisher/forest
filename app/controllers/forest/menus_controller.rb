require_dependency "forest/application_controller"

module Forest
  class MenusController < ApplicationController
    before_action :set_menu, only: [:show, :edit, :update, :destroy]

    layout 'forest/admin'

    # GET /menus
    def index
      @menus = apply_scopes(Menu).page params[:page]
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
        redirect_to @menu, notice: 'Menu was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /menus/1
    def update
      authorize @menu
      if @menu.update(menu_params)
        redirect_to @menu, notice: 'Menu was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /menus/1
    def destroy
      authorize @menu
      @menu.destroy
      redirect_to menus_url, notice: 'Menu was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_menu
        @menu = Menu.friendly.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def menu_params
        params.require(:menu).permit(:title, :slug, :structure)
      end
  end
end
