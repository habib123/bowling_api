class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def routing_error(error = 'Routing error', status = :not_found, exception=nil)
    render json: { status: status, message: error}
  end

  def action_missing(m, *args, &block)
    Rails.logger.error(m)
    redirect_to '/*path'
  end
end
