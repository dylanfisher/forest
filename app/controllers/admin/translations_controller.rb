class Admin::TranslationsController < Admin::ForestController
  before_action :set_translation, only: [:show, :edit, :update, :destroy]

  def index
    @translations = apply_scopes(Translation).by_key.page params[:page]
  end

  def show
    authorize @translation
  end

  def new
    @translation = Translation.new
    authorize @translation
  end

  def edit
    authorize @translation
  end

  def create
    @translation = Translation.new(translation_params)
    authorize @translation

    if @translation.save
      redirect_to edit_admin_translation_path(@translation), notice: 'Translation was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @translation

    if @translation.update(translation_params)
      redirect_to edit_admin_translation_path(@translation), notice: 'Translation was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @translation
    @translation.destroy
    redirect_to admin_translations_url, notice: 'Translation was successfully destroyed.'
  end

  private

    def translation_params
      # Add blockable params to the permitted attributes if this record is blockable `**BlockSlot.blockable_params`
      params.require(:translation).permit(:key, :value, :description, )
    end

    def set_translation
      @translation = Translation.find(params[:id])
    end
end
