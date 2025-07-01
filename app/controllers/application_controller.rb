class ApplicationController < ActionController::API
  before_action :log_cors_origin

  def log_cors_origin
    Rails.logger.info "[CORS] Origin header = #{request.headers['Origin'].inspect}"
    Rails.logger.info "[CORS] Full request URL = #{request.url}"
  end
end
