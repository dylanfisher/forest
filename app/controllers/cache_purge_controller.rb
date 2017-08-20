class CachePurgeController < ForestController
  layout 'admin'

  def index
    authorize :dashboard, :index?

    logger.info "Performing user-issued cache clear"

    Rails.cache.clear

    redirect_to params.delete(:return_to) || admin_path, notice: "Cache has been cleared."
  end
end