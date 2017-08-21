module ForestErrorsHelper
  # Display errors that are only visible to admin users
  def forest_admin_error(error, options = {})
    if Rails.env.production?
      if current_user&.admin?
        logger.error("[Forest] forest_admin_error")
        logger.error(error.message)
        logger.error(error.backtrace.join("\n"))

        error_messages = []
        error_messages << "Error on #{Rails.application.class.parent.to_s.titleize}\n"
        error_messages << "Path: #{request.fullpath}\n"
        error_messages << "#{error.message}\n"
        error_messages << error.backtrace.first(20).join("\n")

        visible_errors_for_admin = []
        visible_errors_for_admin << options.fetch(:message, "Warning: this code block has errors and is not visible to the public.\nYou are seeing this message because you are logged in.\n")
        visible_errors_for_admin << mail_to('mailto:hi@dylanfisher.com',
                                        "Click here to email this error to the developers.\n",
                                        subject: "Error on #{Rails.application.class.parent.to_s.titleize} - #{request.path}",
                                        body: error_messages.join("\n").html_safe,
                                        target: '_blank')
        visible_errors_for_admin << "#{error.message}\n"
        visible_errors_for_admin << error.backtrace.join("\n")

        content_tag :pre do
          visible_errors_for_admin.join("\n").html_safe
        end
      end
    else
      raise error
    end
  end
end
