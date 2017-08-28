<% module_namespacing do -%>
class Admin::<%= class_name %>sController < Admin::ForestController
  before_action :set_<%= singular_name %>, only: [:show, :edit, :update, :destroy]

  def index
    @<%= plural_name %> = apply_scopes(<%= name %>).by_id.page(params[:page])
  end

  def show
    authorize @<%= singular_name %>
  end

  def new
    @<%= singular_name %> = <%= name %>.new
    authorize @<%= singular_name %>
  end

  def edit
    authorize @<%= singular_name %>
  end

  def create
    @<%= singular_name %> = <%= name %>.new(<%= singular_name %>_params)
    authorize @<%= singular_name %>

    if @<%= singular_name %>.save
      redirect_to edit_admin_<%= singular_name %>_path(@<%= singular_name %>), notice: '<%= name %> was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @<%= singular_name %>

    if @<%= singular_name %>.update(<%= singular_name %>_params)
      redirect_to edit_admin_<%= singular_name %>_path(@<%= singular_name %>), notice: '<%= name %> was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @<%= singular_name %>
    @<%= singular_name %>.destroy
    redirect_to admin_<%= plural_name %>_url, notice: '<%= name %> was successfully destroyed.'
  end

  private

    def <%= singular_name %>_params
      # Add blockable params to the permitted attributes if this record is blockable `**BlockSlot.blockable_params`
      # Add :slug, :status
      params.require(:<%= singular_name %>).permit(<%= attributes.collect { |a| ":#{a.name}" }.join(', ') %>)
    end

    def set_<%= singular_name %>
      @<%= singular_name %> = <%= name %>.find(params[:id])
    end
end
<% end -%>
