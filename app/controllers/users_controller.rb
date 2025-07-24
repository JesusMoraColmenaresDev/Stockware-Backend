class UsersController < ApplicationController
  # before_action :authenticate_user!            # require JWT
  # before_action :authorize_user!, only: [ :show, :update ]
  before_action :set_user, only: [ :show, :update ]


  # GET /users (Get ALL)
  def index
    # 1. Empezamos con la consulta base de todos los usuarios, seleccionando los campos necesarios.
    users = User.select(:id, :email, :name, :created_at, :role, :is_enabled).order(:name)

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

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  # Only let users update themselves (or only admins, if you add roles)
  def authorize_user!
    head :forbidden unless current_user.id == @user.id
  end

  def user_params
    # Only allow name & email (and password if you want)
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :is_enabled, :role)
  end
end
