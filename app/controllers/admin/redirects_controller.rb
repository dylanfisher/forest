class Admin::RedirectsController < Admin::ForestController
  before_action :set_redirect, only: [:edit, :update, :destroy]

  def index
    @pagy, @redirects = pagy apply_scopes(Redirect.by_id)
  end

  def new
    @redirect = Redirect.new
    authorize @redirect
  end

  def edit
    authorize @redirect
  end

  def create
    @redirect = Redirect.new(redirect_params)
    authorize @redirect

    if @redirect.save
      redirect_to edit_admin_redirect_path(@redirect), notice: 'Redirect was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @redirect

    if @redirect.update(redirect_params)
      redirect_to edit_admin_redirect_path(@redirect), notice: 'Redirect was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @redirect
    @redirect.destroy
    redirect_to admin_redirects_url, notice: 'Redirect was successfully destroyed.'
  end

  private

  def redirect_params
    params.require(:redirect).permit(:slug, :status, :name, :from_path, :to_path, :redirect_type)
  end

  def set_redirect
    @redirect = Redirect.find(params[:id])
  end
end
