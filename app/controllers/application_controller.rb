class ApplicationController < ActionController::API
  before_action :set_cors_headers

  def set_cors_headers
    response.headers['Access-Control-Allow-Origin'] = 'http://localhost:5173'
    response.headers['Access-Control-Allow-Credentials'] = 'true'
  end
end
