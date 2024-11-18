class Admin::MissionControlController < Admin::ForestController
  before_action :verify

  private

  def verify
    authorize :dashboard, :index?
  end
end
