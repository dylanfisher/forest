<% module_namespacing do -%>
class <%= class_name %>sController < Admin::ForestController
  before_action :set_<%= singular_name %>, only: [:show, :edit, :update, :destroy]

  def index
    @<%= plural_name %> = apply_scopes(<%= name %>).by_id.page params[:page]
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
    @<%= singular_name %> = <%= name %>.new
    authorize @<%= singular_name %>

    # TODO: Handle block type deletion
    parse_block_attributes @<%= singular_name %>, record_type: '<%= singular_name %>'

    @<%= singular_name %>.assign_attributes <%= singular_name %>_params

    respond_to do |format|
      if @<%= singular_name %>.valid?
        save_record @<%= singular_name %>
        format.html { redirect_to edit_admin_<%= singular_name %>_path(@<%= singular_name %>), notice: '<%= name %> was successfully created.' }
        format.json { render :show, status: :created, location: @<%= singular_name %> }
      else
        format.html { render :new }
        format.json { render json: @<%= singular_name %>.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @<%= singular_name %>

    # TODO: Handle block type deletion
    parse_block_attributes @<%= singular_name %>, record_type: '<%= singular_name %>'

    @<%= singular_name %>.assign_attributes <%= singular_name %>_params

    respond_to do |format|
      if @<%= singular_name %>.valid?
        save_record @<%= singular_name %>
        format.html { redirect_to edit_admin_<%= singular_name %>_path(@<%= singular_name %>), notice: '<%= name %> was successfully updated.' }
        format.json { render :show, status: :ok, location: @<%= singular_name %> }
      else
        format.html { render :edit }
        format.json { render json: @<%= singular_name %>.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @<%= singular_name %>
    @<%= singular_name %>.destroy
    respond_to do |format|
      format.html { redirect_to admin_<%= plural_name %>_url, notice: '<%= name %> was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def <%= singular_name %>_params
      params.require(:<%= singular_name %>).permit(:title, :slug, :status, <%= attributes.collect { |a| ":#{a.name}, " }.join %>
        block_slots_attributes: [:id, :_destroy, :block_id, :block_kind, :position, :block_record_type, :block_record_id, *BlockKind.block_kind_params])
    end

    def set_<%= singular_name %>
      if action_name == 'show'
        # TODO: Published scope
        @<%= singular_name %> = <%= name %>.find_by_slug(params[:id]) # Don't eager load associations when cached in show
      else
        @<%= singular_name %> = <%= name %>.includes(block_slots: :block).find_by_slug(params[:id])
      end

      @record = @<%= singular_name %>

      # TODO: update page title as necessary
      @page_title = @<%= singular_name %>.try(:title)
    rescue ActiveRecord::RecordNotFound
      if action_name == 'show' && Rails.env.production?
        redirect_to root_url, flash: { error: 'Record not found.' }
      else
        raise ActiveRecord::RecordNotFound
      end
    end

end
<% end -%>
