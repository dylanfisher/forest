class Admin::BlockKindsController < Admin::ForestController
  before_action :set_block_kind, only: [:edit, :update]

  def index
    @block_kinds = apply_scopes(BlockKind).by_id.page params[:page]
  end

  def edit
    authorize @block_kind
  end

  def update
    authorize @block_kind

    if @block_kind.update(block_kind_params)
      redirect_to edit_admin_block_kind_path(@block_kind), notice: 'BlockKind was successfully updated.'
    else
      render :edit
    end
  end

  private

    def block_kind_params
      params.require(:block_kind).permit(:description, :category)
    end

    def set_block_kind
      @block_kind = BlockKind.find(params[:id])
    end
end
