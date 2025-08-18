class AuthController < ApplicationController
  # ApplicationController already runs `authenticate_user!` for non-devise controllers,
  # so a request with a valid Bearer token will have current_user set.

  # GET /auth/validate
  # Returns 204 No Content when token is valid; 401 when not.
  def validate
    head :no_content
  end
end
