class DocumentationController < ForestController
  layout 'admin'

  def index
    authorize :dashboard, :index?
  end
end
