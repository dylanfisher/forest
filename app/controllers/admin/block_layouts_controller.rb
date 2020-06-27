class Admin::BlockLayoutsController < Admin::ForestController
  before_action :set_block_layout, only: [:edit, :update]

  def index
    @pagy, @block_layouts = pagy apply_scopes(BlockLayout).by_id
  end

  def new
    @block_layout = BlockLayout.new
    authorize @block_layout
  end

  def edit
    authorize @block_layout
  end

  def create
    @block_layout = BlockLayout.new(block_layout_params)
    authorize @block_layout

    if @block_layout.save
      redirect_to edit_admin_block_layout_path(@block_layout), notice: 'BlockLayout was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @block_layout

    if @block_layout.update(block_layout_params)
      redirect_to edit_admin_block_layout_path(@block_layout), notice: 'BlockLayout was successfully updated.'
    else
      render :edit
    end
  end

  private

    def block_layout_params
      params.require(:block_layout).permit(:slug, :display_name, :description)
    end

    def set_block_layout
      @block_layout = BlockLayout.find(params[:id])
    end
end
