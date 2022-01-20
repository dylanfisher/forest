module ForestErrorsHelper
  # Display errors that are only visible to admin users
  def forest_admin_error(error, options = {})
    if Rails.env.production?
      logger.error("[Forest][Error] #{error.class}")
      logger.error(error.message)
      logger.error(error.backtrace.first(10).join("\n"))
    else
      raise error
    end
  end
end
