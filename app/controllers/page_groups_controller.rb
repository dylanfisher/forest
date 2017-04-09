class PageGroupsController < ForestController

  has_scope :title_like

  def index
    @page_groups = apply_scopes(PageGroup.uniq_by_slug.order(:slug)).page params[:page]
    authorize @page_groups
    respond_to :json
  end

end
