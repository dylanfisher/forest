<% module_namespacing do -%>
class Admin::<%= plural_name.camelize %>Controller < Admin::ForestController
  before_action :set_<%= singular_name %>, only: [:edit, :update, :destroy]

  def index
    @pagy, @<%= plural_name %> = pagy apply_scopes(<%= name %>.by_id)
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
<%
      additional_attributes = []
      additional_attributes.prepend(':status') unless options.skip_statusable?
      additional_attributes.prepend(':slug') unless options.skip_sluggable?
      additional_attributes = additional_attributes.join(', ')
      additional_attributes = additional_attributes << ', ' if additional_attributes.present?
-%>
    params.require(:<%= singular_name %>).permit(<%= additional_attributes -%><%= attributes.collect { |a| ":#{a.column_name}" }.join(', ') %>)
  end

  def set_<%= singular_name %>
    @<%= singular_name %> = <%= name %>.find(params[:id])
  end
end
<% end -%>
