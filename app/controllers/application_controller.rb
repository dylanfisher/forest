class ApplicationController < ActionController::Base
  include Pundit::Authorization

  after_action :verify_authorized, unless: :devise_controller?
end
