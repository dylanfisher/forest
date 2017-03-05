<% module_namespacing do -%>
class <%= class_name %>sController < ForestController
  include BlockableControllerConcerns
  include FilterControllerScopes

  layout 'admin', except: [:show]

  before_action :set_<%= singular_name %>, only: [:show, :edit, :update, :destroy, :versions, :version, :restore]
  # before_action :set_paper_trail_whodunnit

  has_scope :by_status

  def index
    @<%= plural_name %> = apply_scopes(<%= name %>).by_id.page params[:page]
  end

  def versions
    authorize @<%= singular_name %>
    @versions = @<%= singular_name %>.versions
    status = params[:by_status] && <%= name %>.statuses[params[:by_status]]
    if status
      @versions = @versions.where_object(status: status)
    end
    @versions = @versions.reorder(created_at: :desc, id: :desc).page params[:page]
  end

  def restore
    authorize @<%= singular_name %>
    @version = @<%= singular_name %>.versions.find(params['version_id'])
    @<%= singular_name %> = @version.reify
    @<%= singular_name %>.reify_page_slots!

    respond_to do |format|
      if @<%= singular_name %>.save
        format.html { redirect_to <%= singular_name %>_versions_path(@<%= singular_name %>), notice: '<%= name %> version was successfully restored.' }
        format.json { render :show, status: :ok, location: @<%= singular_name %> }
      else
        format.html { render :versions }
        format.json { render json: @<%= singular_name %>.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    authorize @<%= singular_name %>
  end

  def version
    authorize @<%= singular_name %>
    @version = @<%= singular_name %>.versions.find(params['version_id'])
    @<%= singular_name %> = @version.reify
    # TODO: some way to reify blocks for other versions
    render :show
  end

  def new
    @<%= singular_name %> = <%= name %>.new
    authorize @<%= singular_name %>
    set_block_record
  end

  def edit
    authorize @<%= singular_name %>
    set_block_record
  end

  def create
    @<%= singular_name %> = <%= name %>.new
    authorize @<%= singular_name %>

    # TODO: Handle block type deletion
    parse_block_attributes @<%= singular_name %>, record_type: '<%= singular_name %>'

    @<%= singular_name %>.assign_attributes <%= singular_name %>_params

    respond_to do |format|
      if @<%= singular_name %>.valid?
        save_page @<%= singular_name %>
        format.html { redirect_to edit_<%= singular_name %>_path(@<%= singular_name %>), notice: '<%= name %> was successfully created.' }
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
        save_page @<%= singular_name %>
        format.html { redirect_to edit_<%= singular_name %>_path(@<%= singular_name %>), notice: '<%= name %> was successfully updated.' }
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
      format.html { redirect_to <%= plural_name %>_url, notice: '<%= name %> was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def <%= singular_name %>_params
      params.require(:<%= singular_name %>).permit(:title, :slug, :status, <%= attributes.collect { |a| ":#{a.name}, " }.join %>
        page_slots_attributes: [:id, :_destroy, :block_id, :block_type, :block_previous_version_id, :position, :block_record_type, :block_record_id, *BlockType.block_type_params])
    end

    def set_<%= singular_name %>
      if action_name == 'show'
        # TODO: Published scope
        @<%= singular_name %> = <%= name %>.friendly.find(params[:id]) # Don't eager load associations when cached in show
      else
        @<%= singular_name %> = <%= name %>.includes(page_slots: :block).friendly.find(params[:id])
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

    def set_block_record
      @block_record = @<%= singular_name %>.block_record || @<%= singular_name %>.build_block_record
    end

end
<% end -%>
