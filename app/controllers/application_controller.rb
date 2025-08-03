# Para una aplicación API (`config.api_only = true`), heredar de ActionController::API
# es la práctica estándar. Carga un conjunto de módulos más ligero y adecuado.
class ApplicationController < ActionController::API
  include Pagy::Backend
  # Incluimos este módulo para poder usar `respond_to` en los controladores
  # y manejar múltiples formatos de respuesta (ej. JSON, PDF).
  include ActionController::MimeResponds

  before_action :log_cors_origin
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, unless: :devise_controller?

  def authenticate_user!
    unless user_signed_in?
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def log_cors_origin
    # Rails.logger.info "[CORS] Origin header = #{request.headers['Origin'].inspect}"
    # Rails.logger.info "[CORS] Full request URL = #{request.url}"
    Rails.logger.debug "[CORS] Origin=#{request.headers['Origin'].inspect}"
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def render_paginated(query, json_options = {})
    @pagy, records = pagy(query)

    metadata = pagy_metadata(@pagy)
    filtered_metadata = metadata.slice(:page, :prev, :next, :pages, :count, :items)

    render json: {
      metadata: filtered_metadata,
      data: records.as_json(json_options)
    }, status: :ok
  end

  # El método `invalid_token` y `respond_to_unauthenticated` ya no son necesarios
  # porque la autenticación se maneja explícitamente y no se usa protección CSRF.
end
