class Admin::SettingsController < Admin::ForestController
  before_action :set_setting, only: [:show, :edit, :update, :destroy]

  has_scope :by_locale, default: I18n.default_locale.to_s, as: :setting_locale

  # GET /settings
  def index
    @pagy, @settings = pagy apply_scopes(Setting.all).by_title
    authorize @settings, :admin_index?
  end

  # GET /settings/1/edit
  def edit
    authorize @setting
  end

  # PATCH/PUT /settings/1
  def update
    authorize @setting
    if @setting.update(setting_params)
      redirect_to edit_admin_setting_path(@setting), notice: 'Setting was successfully updated.'
    else
      render :edit
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_setting
    @setting = Setting.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def setting_params
    params.require(:setting).permit(:value, :title, :slug, :value_type)
  end
end
