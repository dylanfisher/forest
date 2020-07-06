class ErrorsController < ForestController
  before_action :filter_by_request_type

  def not_found
    @page_title = '404 - Not Found'
    render status: 404
  end

  def unprocessable
    @page_title = '422 - Unprocessable'
    render status: 422
  end

  def internal_server_error
    @page_title = '500 - Error'
    render status: 500
  end

  private

  def filter_by_request_type
    if %i(html json).none?(request.format.symbol)
      render status: 404
    end
  end
end
