class ApplicationController < ActionController::API
  before_action :log_cors_origin
    before_action :configure_permitted_parameters, if: :devise_controller?

  def log_cors_origin
    Rails.logger.info "[CORS] Origin header = #{request.headers['Origin'].inspect}"
    Rails.logger.info "[CORS] Full request URL = #{request.url}"
  end

  rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_token

  def authenticate_user!
    unless user_signed_in?
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def invalid_token
    render json: { error: "Invalid or missing token" }, status: :unauthorized
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def respond_to_unauthenticated
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
