class ErrorsController < ForestController
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
end
