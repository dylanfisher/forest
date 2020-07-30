class Admin::CachePurgeController < Admin::ForestController
  def index
    authorize :dashboard, :index?

    logger.info "[Forest] Performing user-issued cache clear"

    Rails.cache.clear
    Setting.expire_application_cache_key!

    redirect_to params.delete(:return_to) || admin_path, notice: "Cache has been cleared."
  end
end
