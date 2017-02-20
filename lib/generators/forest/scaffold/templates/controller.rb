require_dependency "forest/application_controller"

<% module_namespacing do -%>
class <%= class_name %>sController < ApplicationController
  include BlockableControllerConcerns
  include FilterControllerScopes

  layout 'forest/admin', except: [:show]

  before_action :set_<%= singular_name %>, only: [:show, :edit, :update, :destroy, :versions, :version, :restore]
  before_action :set_blockable_record, only: [:edit, :update, :create]
  # before_action :set_paper_trail_whodunnit

  has_scope :by_status

  def index
    @<%= plural_name %> = apply_scopes(<%= name %>).page params[:page]
    authorize @<%= @plural_name %>
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
        format.html { redirect_to <%= singular_name %>_versions_path(@<%= singular_name %>), notice: 'Page version was successfully restored.' }
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
  end

  def edit
    authorize @<%= singular_name %>
  end

  def create
    @<%= singular_name %> = <%= name %>.new
    authorize @<%= singular_name %>

    # TODO: Handle block type deletion
    parse_block_attributes

    @<%= singular_name %>.assign_attributes <%= singular_name %>_params

    respond_to do |format|
      if @<%= singular_name %>.valid?
        save_page
        format.html { redirect_to edit_<%= singular_name %>_path(@<%= singular_name %>), notice: 'Page was successfully created.' }
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
    parse_block_attributes

    @<%= singular_name %>.assign_attributes <%= singular_name %>_params

    respond_to do |format|
      if @<%= singular_name %>.valid?
        save_page
        format.html { redirect_to edit_<%= singular_name %>_path(@<%= singular_name %>), notice: 'Page was successfully updated.' }
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
      format.html { redirect_to <%= plural_name %>_url, notice: 'Page was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def <%= singular_name %>_params
      params.require(:<%= singular_name %>).permit(:title, :slug,
        page_slots_attributes: [:id, :_destroy, :blockable_id, :blockable_type, :blockable_previous_version_id, :position, :blockable_record_type, :blockable_record_id, *BlockType.block_type_params])
    end

    def set_<%= singular_name %>
      @<%= singular_name %> = <%= name %>.friendly.find(params[:id])
      if action_name == 'show'
        # Don't eager load associations when cached in show
        @<%= singular_name %> = <%= name %>.friendly.find(params[:id])
      else
        @<%= singular_name %> = <%= name %>.includes(page_slots: :blockable).friendly.find(params[:id])
      end

      @<%= singular_name %>_title = @<%= singular_name %>.title
      # TODO: Published scope
      # @<%= singular_name %> = <%= name %>.friendly.find(params[:id]).versions.where_object(status: 1).last.reify
    rescue ActiveRecord::RecordNotFound
      if action_name == 'show' && Rails.env.production?
        redirect_to root_url, flash: { error: 'Record not found.' }
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    def set_blockable_record
      @blockable_record = @<%= singular_name %>.blockable_record || @<%= singular_name %>.build_blockable_record
    end

end
<% end -%>
