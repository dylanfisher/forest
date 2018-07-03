class Admin::VersionsController < Admin::ForestController
  before_action :set_version, only: [:show, :edit, :update, :destroy]

  def index
    @versions = apply_scopes(forest/version).by_id.page(params[:page])
  end

  def show
    authorize @version
  end

  def new
    @version = forest/version.new
    authorize @version
  end

  def edit
    authorize @version
  end

  def create
    @version = forest/version.new(version_params)
    authorize @version

    if @version.save
      redirect_to edit_admin_version_path(@version), notice: 'forest/version was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @version

    if @version.update(version_params)
      redirect_to edit_admin_version_path(@version), notice: 'forest/version was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @version
    @version.destroy
    redirect_to admin_versions_url, notice: 'forest/version was successfully destroyed.'
  end

  private

    def version_params
      # Add blockable params to the permitted attributes if this record is blockable `**BlockSlot.blockable_params`
      params.require(:version).permit(:slug, :status, :record)
    end

    def set_version
      @version = forest/version.find(params[:id])
    end
end
