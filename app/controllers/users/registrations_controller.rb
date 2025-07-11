class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

    #ESTE MÉTODO PARA DESACTIVAR EL AUTO-LOGIN
  def sign_up(resource_name, resource)
    
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: resource, status: :created
    else
      render json: { errors: resource.errors }, status: :unprocessable_entity
    end
  end
end