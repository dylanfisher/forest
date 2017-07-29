class ImportsController < ForestController
  layout 'admin'

  before_action :set_import, only: [:edit]

  def edit
    respond_to do |format|
      format.html
      format.csv {
        send_data @import.to_csv_template, filename: "#{@import.to_s.parameterize.underscore}-import-template.csv"
      }
    end
  end

  def create
    klass = params[:import][:model_name].constantize
    file = params[:import][:file]

    Import.new(klass, file)

    redirect_to edit_import_path(klass.model_name.singular), notice: 'Import has been started'
  end

  private

    def import_params
    end

    def set_import
      @import = params[:id].camelcase.constantize
    end
end
