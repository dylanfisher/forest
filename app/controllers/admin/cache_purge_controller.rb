class Admin::CachePurgeController < Admin::ForestController
  def index
    authorize :dashboard, :index?

    logger.info "[Forest] Performing user-issued cache clear"

    Rails.cache.clear

    redirect_to params.delete(:return_to) || admin_path, notice: "Cache has been cleared."
  end
end
