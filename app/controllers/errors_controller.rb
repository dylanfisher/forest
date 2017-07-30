class ErrorsController < ForestController
  before_action :set_layout

  def not_found
    render status: 404
  end

  def internal_server_error
    render status: 500
  end

  private

    def set_layout
      # TODO: figure outhow to determine layout in errors controller
      if admin?
        self.class.layout 'admin'
      else
        self.class.layout 'public'
      end
    end
end
