class Admin::SettingsController < Admin::ForestController
  before_action :set_setting, only: [:show, :edit, :update, :destroy]

  has_scope :by_locale, default: I18n.default_locale.to_s, as: :setting_locale

  # GET /settings
  def index
    @settings = apply_scopes(Setting.all).by_title.page params[:page]
    authorize @settings
  end

  # GET /settings/1
  def show
    authorize @setting
  end

  # GET /settings/new
  # def new
  #   @setting = Setting.new
  #   authorize @setting
  # end

  # GET /settings/1/edit
  def edit
    authorize @setting
  end

  # POST /settings
  def create
    @setting = Setting.new(setting_params)
    authorize @setting

    if @setting.save
      redirect_to edit_admin_setting_path(@setting), notice: 'Setting was successfully created.'
    else
      render :new
    end
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

  # DELETE /settings/1
  # def destroy
  #   authorize @setting
  #   @setting.destroy
  #   redirect_to admin_settings_url, notice: 'Setting was successfully destroyed.'
  # end

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
