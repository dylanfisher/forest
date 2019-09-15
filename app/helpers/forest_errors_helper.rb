module ForestErrorsHelper
  # Display errors that are only visible to admin users
  def forest_admin_error(error, options = {})
    if Rails.env.production?
      if current_user&.admin?
        logger.error("[Forest] forest_admin_error")
        logger.error(error.message)

        visible_errors_for_admin = []
        visible_errors_for_admin << options.fetch(:message, "Warning: this code block has errors and is not visible to the public.\nYou are seeing this message because you are an admin.\n")
        visible_errors_for_admin << "#{error.message}\n"

        content_tag :pre, class: 'admin-error-message' do
          visible_errors_for_admin.join("\n").html_safe
        end
      end
    else
      raise error
    end
  end
end
