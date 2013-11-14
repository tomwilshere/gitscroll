class ApplicationController < ActionController::Base
  protect_from_forgery

  def not_found(message)
    raise ActionController::RoutingError.new(message)
  end
end
