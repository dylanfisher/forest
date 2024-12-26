module Forest
  class ApplicationController < ActionController::Base
    include Forest::Authentication
  end
end
