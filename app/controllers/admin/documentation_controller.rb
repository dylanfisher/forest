class Admin::DocumentationController < Admin::ForestController
  def index
    authorize :dashboard, :index?
  end
end
