class UsersController < ApplicationController
  # before_action :authenticate_user!            # require JWT
  # before_action :authorize_user!, only: [ :show, :update ]
  before_action :set_user, only: [ :show, :update ]

  # GET /users (Get ALL)
  def index
    # 1. Empezamos con la consulta base de todos los usuarios, seleccionando los campos necesarios.
    users = User.where(is_enabled: true).select(:id, :email, :name, :created_at, :role, :is_enabled).order(:name)

    # 2. Si el parámetro 'search' está presente, filtramos por nombre o email.
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      users = users.where("name ILIKE ?", search_term)
    end

    # 3. Pasamos la consulta (original o filtrada) a nuestro método de paginación.
    render_paginated(users)
  end

  # GET /users/all
  def all
    # Solo para Admin?
    users = User.all.select(:id, :email, :name, :role, :is_enabled)
    render json: users, status: :ok
  end

  # GET /users/:id (Get By id)
  def show
    render json: @user.slice(:id, :email, :name, :created_at, :role, :is_enabled), status: :ok  # Del usuario especifico, nos taremos solo lo publico
  end

  # PATCH /users/:id
  # body: { user: { name: "New Name", email: "new@example.com" } }
  def update
    if @user.update(user_params)  # Encuentra el usuario con los parametros respectivos?
      render json: @user.slice(:id, :email, :name, :is_enabled, :role), status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /profile
  def update_profile
    # Primero, vemos si el usuario está intentando cambiar su email.
    needs_password = profile_params[:email].present? && profile_params[:email] != current_user.email

    if needs_password
      # Si quiere cambiar el email, usamos el método seguro de Devise.
      if current_user.update_with_password(profile_params)
        render json: current_user.slice(:id, :email, :name), status: :ok
      else
        render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      # Si solo cambia el nombre, usamos el update normal.
      if current_user.update(profile_params)
        render json: current_user.slice(:id, :email, :name), status: :ok
      else
        render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  # PATCH /password
  def update_password
    # Este método está dedicado únicamente a cambiar la contraseña.
    # Usa `update_with_password` de Devise, que requiere la contraseña actual.
    if current_user.update_with_password(password_params)
      head :no_content # Éxito, no es necesario devolver un cuerpo.
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /profile
  def destroy_profile
    # Verificamos que la contraseña proporcionada sea correcta.
    if current_user.valid_password?(delete_account_params[:current_password])
      current_user.destroy
      sign_out current_user # Invalidamos la sesión/token de Devise.
      head :no_content
    else
      render json: { errors: [ "Incorrect password. Account not deleted." ] }, status: :unauthorized
    end
  end

  # PATCH /profile/disable
  def disable_own_account
    # Verificamos que la contraseña proporcionada sea correcta.
    if current_user.valid_password?(disable_account_params[:current_password])
      current_user.update(is_enabled: false)
      sign_out current_user # Invalidamos la sesión/token de Devise.
      render json: { message: "Account successfully disabled." }, status: :ok
    else
      render json: { errors: [ "Incorrect password. Account not disabled." ] }, status: :unauthorized
    end
  end

  # GET /profile
  def profile
    # El `before_action :authenticate_user!` en ApplicationController ya se encargó
    # de verificar el token y cargar el usuario en `current_user`.
    # Simplemente devolvemos los datos del usuario actual.
    render json: current_user.slice(:id, :email, :name, :created_at, :role, :is_enabled), status: :ok
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def authorize_user!
    head :forbidden unless current_user.id == @user.id
  end

  def authorize!
    # only admins can list or update arbitrary users;
    # allow users to see/update themselves if you prefer
    head :forbidden unless current_user.role == "admin"
  end

  def user_params
    # Only allow name & email (and password if you want)
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :is_enabled, :role)
  end

  def profile_params
    # Un usuario solo debe poder actualizar su nombre, email y contraseña.
    # No debe poder cambiar su rol o estado de habilitado.
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
  end

  def password_params
    # Parámetros permitidos exclusivamente para el cambio de contraseña.
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def delete_account_params
    params.require(:user).permit(:current_password)
  end

  def disable_account_params
    params.require(:user).permit(:current_password)
  end
end
