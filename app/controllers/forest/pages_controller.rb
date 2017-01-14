require_dependency "forest/application_controller"

module Forest
  class PagesController < ApplicationController
    include FilterControllerScopes

    layout 'forest/admin', except: [:show]

    before_action :set_page, only: [:show, :edit, :update, :destroy, :versions, :version, :restore]
    before_action :set_paper_trail_whodunnit

    has_scope :by_status

    # GET /pages
    # GET /pages.json
    def index
      @pages = apply_scopes(Page.includes(:versions)).by_title.page params[:page]
      authorize @pages
    end

    # GET /pages/1/versions
    # GET /pages/1/versions.json
    def versions
      authorize @page
      @versions = @page.versions
      status = params[:by_status] && Page.statuses[params[:by_status]]
      if status
        @versions = @versions.where_object(status: status)
      end
      @versions = @versions.reorder(created_at: :desc, id: :desc).page params[:page]
    end

    # GET /pages/1/restore
    # GET /pages/1/restore.json
    def restore
      authorize @page
      @version = @page.versions.find(params['version_id'])
      @page = @version.reify

      respond_to do |format|
        if @page.save
          format.html { redirect_to page_versions_path(@page), notice: 'Page version was successfully restored.' }
          format.json { render :show, status: :ok, location: @page }
        else
          format.html { render :versions }
          format.json { render json: @page.errors, status: :unprocessable_entity }
        end
      end
    end

    # GET /pages/1
    # GET /pages/1.json
    def show
      authorize @page
    end

    def version
      authorize @page
      @version = @page.versions.find(params['version_id'])
      @page = @version.reify
      render :show
    end

    # GET /pages/new
    def new
      @page = Page.new
      authorize @page
    end

    # GET /pages/1/edit
    def edit
      authorize @page
    end

    # POST /pages
    # POST /pages.json
    def create
      @page = Page.new(page_params)
      authorize @page

      respond_to do |format|
        if @page.save
          format.html { redirect_to @page, notice: 'Page was successfully created.' }
          format.json { render :show, status: :created, location: @page }
        else
          format.html { render :new }
          format.json { render json: @page.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /pages/1
    # PATCH/PUT /pages/1.json
    def update
      authorize @page

      @blocks = {}

      # TODO: Handle block type deletion

      params[:page][:page_slots_attributes] && params[:page][:page_slots_attributes].each_pair do |index, blockable_params|
        block_type = blockable_params['blockable_type']
        block_constant = block_type.safe_constantize
        block_fields = blockable_params['block_fields']
        position = blockable_params['position']
        blockable_id = params[:page][:page_slots_attributes][index][:blockable_id]

        next if block_fields.nil?

        if blockable_id.present?
          block = block_constant.find blockable_id
          existing_attributes = HashWithIndifferentAccess.new
          block.permitted_params.each { |a| existing_attributes[a] = block[a] }
        else
          block = block_type.safe_constantize.new
        end

        new_attributes = block_fields.permit block.permitted_params

        # TODO: not sure if a more precise diff between hashes is necessary
        if block.new_record? || (existing_attributes.to_a - new_attributes.as_json.to_a).present?
          block.assign_attributes block_fields.permit(block.permitted_params)
          @blocks[position] = block
        end

        params[:page][:page_slots_attributes][index].delete :block_fields
      end

      respond_to do |format|
        if @page.update(page_params)
          save_blocks
          format.html { redirect_to edit_page_path(@page), notice: 'Page was successfully updated.' }
          format.json { render :show, status: :ok, location: @page }
        else
          format.html { render :edit }
          format.json { render json: @page.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /pages/1
    # DELETE /pages/1.json
    def destroy
      authorize @page
      @page.destroy
      respond_to do |format|
        format.html { redirect_to pages_url, notice: 'Page was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_page
        @page = Page.friendly.find(params[:id])
        # TODO: Published page scope. Maybe add a association on Page so that a page has_one current_published_version.
        # This could be set in a after_save filter when updating page statuses.
        # @page = Page.friendly.find(params[:id]).versions.where_object(status: 1).last.reify
      rescue ActiveRecord::RecordNotFound
        if action_name == 'show' && Rails.env.production?
          redirect_to root_url, flash: { error: 'Record not found.' }
        else
          raise ActiveRecord::RecordNotFound
        end
      end

      def save_blocks
        return unless @blocks.present?
        @blocks.each_pair do |position, block|
          if block.save
            # TODO: this is feeling a little brittle
            @page.page_slots.select { |a| a.position == position.to_i }.first.update_column :blockable_id, block.id
          else
            format.html { render :edit, notice: "Unable to update #{block.class.name.titleize}." }
          end
        end
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def page_params
        params.require(:page).permit(:title, :slug, :description, :status, :version_id, :featured_image_id, :media_item_ids,
          page_slots_attributes: [:id, :_destroy, :page_id, :page_version_id, :blockable_id, :blockable_type, :blockable_version_id, :position, *BlockType.block_type_params])
      end
  end
end
